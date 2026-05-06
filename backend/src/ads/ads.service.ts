import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class AdsService {
  constructor(private supabase: SupabaseService) {}

  async findActive() {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('ads')
      .select('id, title, image_url, link_url, impressions, clicks')
      .eq('status', 'ativo')
      .order('created_at', { ascending: false });

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async trackImpression(adId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('ads')
      .select('impressions')
      .eq('id', adId)
      .single();

    if (error || !data) throw new NotFoundException('Anúncio não encontrado');

    await this.supabase
      .getAdminClient()
      .from('ads')
      .update({ impressions: (data.impressions ?? 0) + 1 })
      .eq('id', adId);

    return { ok: true };
  }

  async trackClick(adId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('ads')
      .select('clicks')
      .eq('id', adId)
      .single();

    if (error || !data) throw new NotFoundException('Anúncio não encontrado');

    await this.supabase
      .getAdminClient()
      .from('ads')
      .update({ clicks: (data.clicks ?? 0) + 1 })
      .eq('id', adId);

    return { ok: true };
  }
}
