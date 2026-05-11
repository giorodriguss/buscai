import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class TagsService {
  private readonly logger = new Logger(TagsService.name);

  constructor(private supabase: SupabaseService) {}

  async findAll() {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('tags')
      .select('id, name, slug')
      .order('name');

    if (error) {
      this.logger.error(`Find tags failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar as tags');
    }
    return data;
  }
}
