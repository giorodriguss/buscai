import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';

@Injectable()
export class PostsService {
  constructor(private supabase: SupabaseService) {}

  async create(userId: string, dto: CreatePostDto) {
    // Check subscription post limit
    const { data: sub } = await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .select('max_posts')
      .eq('user_id', userId)
      .single();

    const { count: postCount } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('status', 'ativo');

    const maxPosts = sub?.max_posts ?? 1;
    if ((postCount ?? 0) >= maxPosts) {
      throw new BadRequestException(
        `Seu plano permite no máximo ${maxPosts} post(s) ativo(s)`,
      );
    }

    const { tag_ids, ...postData } = dto;

    const { data: post, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .insert({ ...postData, user_id: userId, status: 'ativo' })
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);

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

    if (q) query = query.ilike('title', `%${q}%`);
    if (category_id) query = query.eq('category_id', category_id);
    if (neighborhood) query = query.ilike('neighborhood', `%${neighborhood}%`);
    if (city) query = query.ilike('city', `%${city}%`);
    if (state) query = query.eq('state', state);

    const { data, error, count } = await query;
    if (error) throw new BadRequestException(error.message);

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

  async update(id: string, userId: string, dto: UpdatePostDto) {
    await this.assertOwner(id, userId);

    const { tag_ids, ...postData } = dto;

    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .update(postData)
      .eq('id', id)
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);

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

  async remove(id: string, userId: string) {
    await this.assertOwner(id, userId);

    const { error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .delete()
      .eq('id', id);

    if (error) throw new BadRequestException(error.message);
    return { message: 'Post removido' };
  }

  async findByUser(userId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select(
        'id, title, price_from, price_to, whatsapp, neighborhood, city, state, views_count, status, created_at, post_photos(storage_url, sort_order)',
      )
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw new BadRequestException(error.message);
    return data?.map(this.addWhatsappLink);
  }

  private async assertOwner(postId: string, userId: string) {
    const { data } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select('user_id')
      .eq('id', postId)
      .single();

    if (!data) throw new NotFoundException('Post não encontrado');
    if (data.user_id !== userId) throw new ForbiddenException();
  }

  private addWhatsappLink(post: any) {
    if (!post) return post;
    return {
      ...post,
      whatsapp_link: post.whatsapp ? `https://wa.me/55${post.whatsapp}` : null,
    };
  }
}
