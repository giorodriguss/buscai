import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class CategoriesService {
  private readonly logger = new Logger(CategoriesService.name);

  constructor(private supabase: SupabaseService) {}

  async findAll() {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('categories')
      .select('id, name, slug, icon_name, color_hex')
      .eq('is_active', true)
      .order('name');

    if (error) {
      this.logger.error(`Find categories failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar as categorias');
    }
    return data;
  }
}
