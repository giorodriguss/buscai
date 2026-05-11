import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class AdsService {
  private readonly logger = new Logger(AdsService.name);

  constructor(private supabase: SupabaseService) {}

  async findActive() {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('ads')
      .select('id, title, image_url, link_url, impressions, clicks')
      .eq('status', 'ativo')
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Find active ads failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar os anúncios');
    }
    return data;
  }

  async trackImpression(adId: string) {
    const { error } = await this.supabase
      .getAdminClient()
      .rpc('increment_ad_impressions', { p_ad_id: adId });

    if (error) {
      this.logger.error(`Track impression for ad ${adId} failed: ${error.message}`);
      throw new NotFoundException('Anúncio não encontrado');
    }
    return { ok: true };
  }

  async trackClick(adId: string) {
    const { error } = await this.supabase
      .getAdminClient()
      .rpc('increment_ad_clicks', { p_ad_id: adId });

    if (error) {
      this.logger.error(`Track click for ad ${adId} failed: ${error.message}`);
      throw new NotFoundException('Anúncio não encontrado');
    }
    return { ok: true };
  }
}
