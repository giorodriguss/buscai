import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class CategoriesService {
  constructor(private supabase: SupabaseService) {}

  async findAll() {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('categories')
      .select('id, name, slug, icon_name, color_hex')
      .eq('is_active', true)
      .order('name');

    if (error) throw new Error(error.message);
    return data;
  }
}
