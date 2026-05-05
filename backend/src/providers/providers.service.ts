import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateProviderDto } from './dto/create-provider.dto';
import { UpdateProviderDto } from './dto/update-provider.dto';
import { SearchProvidersDto } from './dto/search-providers.dto';

@Injectable()
export class ProvidersService {
  constructor(private supabase: SupabaseService) {}

  async create(userId: string, dto: CreateProviderDto) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('providers')
      .insert({ id: userId, ...dto })
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findAll(query: SearchProvidersDto) {
    const { page = 1, limit = 10, neighborhood, category_id } = query;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let req = this.supabase
      .getAdminClient()
      .from('providers')
      .select(
        `
        *,
        profiles!inner(id, name, avatar_url, neighborhood),
        categories(id, name, slug, icon),
        portfolio_images(id, url)
      `,
        { count: 'exact' },
      )
      .eq('is_active', true)
      .order('rating_avg', { ascending: false })
      .range(from, to);

    if (neighborhood) {
      req = req.ilike('neighborhood', `%${neighborhood}%`);
    }

    if (category_id) {
      req = req.eq('category_id', category_id);
    }

    const { data, error, count } = await req;
    if (error) throw new BadRequestException(error.message);

    return {
      data,
      meta: {
        total: count ?? 0,
        page,
        limit,
        total_pages: Math.ceil((count ?? 0) / limit),
      },
    };
  }

  async findOne(id: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('providers')
      .select(
        `
        *,
        profiles!inner(id, name, avatar_url, neighborhood),
        categories(id, name, slug, icon),
        portfolio_images(id, url),
        reviews(id, rating, comment, created_at, profiles(id, name, avatar_url))
      `,
      )
      .eq('id', id)
      .eq('is_active', true)
      .single();

    if (error || !data) throw new NotFoundException('Prestador não encontrado');
    return data;
  }

  async update(userId: string, dto: UpdateProviderDto) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('providers')
      .update(dto)
      .eq('id', userId)
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async deactivate(userId: string) {
    const { error } = await this.supabase
      .getAdminClient()
      .from('providers')
      .update({ is_active: false })
      .eq('id', userId);

    if (error) throw new BadRequestException(error.message);
    return { message: 'Perfil desativado' };
  }
}
