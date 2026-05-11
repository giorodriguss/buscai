import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class SubscriptionsService {
  constructor(private supabase: SupabaseService) {}

  async findByUser(token: string) {
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('subscriptions')
      .select('id, plan, status, max_posts, max_photos, created_at, updated_at')
      .single();

    if (error || !data) throw new NotFoundException('Assinatura não encontrada');
    return data;
  }
}
