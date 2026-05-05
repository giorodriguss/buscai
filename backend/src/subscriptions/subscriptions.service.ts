import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class SubscriptionsService {
  constructor(private supabase: SupabaseService) {}

  async findByUser(userId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .select('id, plan, status, max_posts, max_photos, created_at, updated_at')
      .eq('user_id', userId)
      .single();

    if (error || !data) throw new NotFoundException('Assinatura não encontrada');
    return data;
  }
}
