import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class FavoritesService {
  private readonly logger = new Logger(FavoritesService.name);

  constructor(private supabase: SupabaseService) {}

  async add(postId: string, token: string) {
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('favorites')
      .insert({ post_id: postId })
      .select()
      .single();

    if (error) {
      this.logger.error(`Add favorite failed: ${error.message}`);
      throw new BadRequestException('Não foi possível adicionar aos favoritos');
    }
    return data;
  }

  async remove(postId: string, token: string) {
    const { error } = await this.supabase
      .getUserClient(token)
      .from('favorites')
      .delete()
      .eq('post_id', postId);

    if (error) {
      this.logger.error(`Remove favorite failed: ${error.message}`);
      throw new BadRequestException('Não foi possível remover dos favoritos');
    }
    return { message: 'Favorito removido' };
  }

  async findByUser(token: string) {
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('favorites')
      .select(
        'id, created_at, posts(id, title, price_from, price_to, whatsapp, neighborhood, city, state, views_count, post_photos(storage_url, sort_order))',
      )
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Find favorites failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar os favoritos');
    }
    return data?.map((fav: any) => ({
      ...fav,
      posts: fav.posts
        ? {
            ...fav.posts,
            whatsapp_link: fav.posts.whatsapp
              ? `https://wa.me/55${fav.posts.whatsapp}`
              : null,
          }
        : null,
    }));
  }
}
