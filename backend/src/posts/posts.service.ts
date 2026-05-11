import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { FREE_PLAN_MAX_POSTS } from '../common/constants';

@Injectable()
export class PostsService {
  private readonly logger = new Logger(PostsService.name);

  constructor(private supabase: SupabaseService) {}

  async create(userId: string, dto: CreatePostDto) {
    const { data: sub } = await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .select('max_posts')
      .eq('user_id', userId)
      .single();

    const maxPosts = sub?.max_posts ?? FREE_PLAN_MAX_POSTS;
    const { tag_ids, ...postData } = dto;

    // RPC atômica: verifica o limite e insere em uma única transação
    const { data: rows, error } = await this.supabase
      .getAdminClient()
      .rpc('create_post_atomic', {
        p_user_id:      userId,
        p_max_posts:    maxPosts,
        p_title:        postData.title,
        p_description:  postData.description  ?? null,
        p_category_id:  postData.category_id,
        p_whatsapp:     postData.whatsapp,
        p_price_from:   postData.price_from   ?? null,
        p_price_to:     postData.price_to     ?? null,
        p_neighborhood: postData.neighborhood ?? null,
        p_city:         postData.city         ?? null,
        p_state:        postData.state        ?? null,
      });

    if (error) {
      if (error.message.includes('LIMIT_REACHED')) {
        throw new BadRequestException(`Seu plano permite no máximo ${maxPosts} post(s) ativo(s)`);
      }
      this.logger.error(`Create post RPC failed for user ${userId}: ${error.message}`);
      throw new BadRequestException('Não foi possível criar o post');
    }

    const post = Array.isArray(rows) ? rows[0] : rows;

    if (tag_ids?.length) {
      await this.supabase
        .getAdminClient()
        .from('post_tags')
        .insert(tag_ids.map((tag_id) => ({ post_id: post.id, tag_id })));
    }

    return this.findOne(post.id);
  }

  async findAll(dto: SearchPostsDto) {
    const { q, category_id, neighborhood, city, state, page = 1, limit = 20 } = dto;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let query = this.supabase
      .getAdminClient()
      .from('posts')
      .select(
        'id, title, description, price_from, price_to, whatsapp, neighborhood, city, state, views_count, status, created_at, users(id, full_name, avatar_url), categories(id, name, icon_name, color_hex), post_photos(storage_url, sort_order)',
        { count: 'exact' },
      )
      .eq('status', 'ativo')
      .order('created_at', { ascending: false })
      .range(from, to);

    if (q) {
      const safeQ = q.replace(/%/g, '\\%').replace(/_/g, '\\_');
      query = query.ilike('title', `%${safeQ}%`);
    }
    if (category_id) query = query.eq('category_id', category_id);
    if (neighborhood) query = query.ilike('neighborhood', `%${neighborhood}%`);
    if (city) query = query.ilike('city', `%${city}%`);
    if (state) query = query.eq('state', state);

    const { data, error, count } = await query;
    if (error) {
      this.logger.error(`Search posts failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar os posts');
    }

    return {
      data: data?.map(this.addWhatsappLink),
      total: count,
      page,
      limit,
    };
  }

  async findOne(id: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select(
        'id, title, description, price_from, price_to, whatsapp, neighborhood, city, state, views_count, status, created_at, updated_at, users(id, full_name, avatar_url, phone, bio), categories(id, name, icon_name, color_hex), post_photos(id, storage_url, caption, sort_order), post_tags(tags(id, name, slug))',
      )
      .eq('id', id)
      .single();

    if (error || !data) throw new NotFoundException('Post não encontrado');

    // Increment views
    await this.supabase
      .getAdminClient()
      .from('posts')
      .update({ views_count: (data.views_count ?? 0) + 1 })
      .eq('id', id);

    return this.addWhatsappLink(data);
  }

  async update(id: string, dto: UpdatePostDto, token: string) {
    const userClient = this.supabase.getUserClient(token);
    const { tag_ids, ...postData } = dto;

    // user client aplica RLS: só afeta posts onde user_id = auth.uid()
    const { error } = await userClient
      .from('posts')
      .update(postData)
      .eq('id', id);

    if (error) {
      // RLS silencia acesso negado como "0 rows" — um erro aqui é infraestrutura
      if (error.message.includes('row-level security')) {
        throw new ForbiddenException();
      }
      this.logger.error(`Update post ${id} failed: ${error.message}`);
      throw new BadRequestException('Não foi possível atualizar o post');
    }

    if (tag_ids !== undefined) {
      await this.supabase.getAdminClient().from('post_tags').delete().eq('post_id', id);
      if (tag_ids.length) {
        await this.supabase
          .getAdminClient()
          .from('post_tags')
          .insert(tag_ids.map((tag_id) => ({ post_id: id, tag_id })));
      }
    }

    return this.findOne(id);
  }

  async remove(id: string, token: string) {
    const userClient = this.supabase.getUserClient(token);

    // user client aplica RLS: só deleta se user_id = auth.uid()
    const { error } = await userClient
      .from('posts')
      .delete()
      .eq('id', id);

    if (error) {
      this.logger.error(`Delete post ${id} failed: ${error.message}`);
      throw new BadRequestException('Não foi possível remover o post');
    }
    return { message: 'Post removido' };
  }

  async findByUser(token: string) {
    const userClient = this.supabase.getUserClient(token);

    // RLS retorna apenas os posts do usuário autenticado (ALL policy)
    const { data, error } = await userClient
      .from('posts')
      .select(
        'id, title, price_from, price_to, whatsapp, neighborhood, city, state, views_count, status, created_at, post_photos(storage_url, sort_order)',
      )
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Find posts by user failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar os posts');
    }
    return data?.map(this.addWhatsappLink);
  }

  private addWhatsappLink(post: any) {
    if (!post) return post;
    return {
      ...post,
      whatsapp_link: post.whatsapp ? `https://wa.me/55${post.whatsapp}` : null,
    };
  }
}
