import { BadRequestException, Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class FavoritesService {
  constructor(private supabase: SupabaseService) {}

  async add(userId: string, postId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('favorites')
      .insert({ user_id: userId, post_id: postId })
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async remove(userId: string, postId: string) {
    const { error } = await this.supabase
      .getAdminClient()
      .from('favorites')
      .delete()
      .eq('user_id', userId)
      .eq('post_id', postId);

    if (error) throw new BadRequestException(error.message);
    return { message: 'Favorito removido' };
  }

  async findByUser(userId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('favorites')
      .select(
        'id, created_at, posts(id, title, price_from, price_to, whatsapp, neighborhood, city, state, views_count, post_photos(storage_url, sort_order))',
      )
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw new BadRequestException(error.message);
    return data;
  }
}
