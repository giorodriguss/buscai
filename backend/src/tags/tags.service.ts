import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class TagsService {
  constructor(private supabase: SupabaseService) {}

  async findAll() {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('tags')
      .select('id, name, slug')
      .order('name');

    if (error) throw new Error(error.message);
    return data;
  }
}
