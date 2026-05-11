import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateProviderDto } from './dto/create-provider.dto';
import { UpdateProviderDto } from './dto/update-provider.dto';
import { SearchProvidersDto } from './dto/search-providers.dto';

const PROVIDER_SELECT = `
  *,
  users(id, full_name, avatar_url),
  categories(id, name, icon_name, color_hex),
  post_photos(id, storage_url, sort_order),
  reviews(id, rating, comment, created_at, users(id, full_name, avatar_url))
`;

@Injectable()
export class ProvidersService {
  constructor(private supabase: SupabaseService) {}

  async create(userId: string, dto: CreateProviderDto) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .insert({ user_id: userId, status: 'ativo', ...dto })
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async findAll(query: SearchProvidersDto) {
    const {
      page = 1,
      limit = 10,
      neighborhood,
      city,
      state,
      category_id,
      lat,
      lng,
      radius_km,
    } = query;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    // Radius search via PostGIS RPC
    if (lat !== undefined && lng !== undefined) {
      const km = radius_km ?? 10;
      const { data: nearby, error: rpcError } = await this.supabase
        .getAdminClient()
        .rpc('providers_nearby', {
          p_lat: lat,
          p_lng: lng,
          p_radius_km: km,
          p_page: page,
          p_limit: limit,
        });

      if (rpcError) throw new BadRequestException(rpcError.message);

      const ids: string[] = (nearby ?? []).map((r: any) => r.id);
      if (ids.length === 0) {
        return { data: [], meta: { total: 0, page, limit, total_pages: 0 } };
      }

      const { data, error } = await this.supabase
        .getAdminClient()
        .from('posts')
        .select(PROVIDER_SELECT)
        .in('id', ids);

      if (error) throw new BadRequestException(error.message);

      const distanceMap = new Map(
        (nearby ?? []).map((r: any) => [r.id, r.distance_km]),
      );
      const sorted = ids
        .map((id) => (data ?? []).find((p: any) => p.id === id))
        .filter(Boolean)
        .map((p: any) => ({ ...p, distance_km: distanceMap.get(p.id) }));

      return { data: sorted, meta: { total: sorted.length, page, limit, total_pages: 1 } };
    }

    // Normal paginated query
    let req = this.supabase
      .getAdminClient()
      .from('posts')
      .select(PROVIDER_SELECT, { count: 'exact' })
      .eq('status', 'ativo')
      .order('created_at', { ascending: false })
      .range(from, to);

    if (neighborhood) req = req.ilike('neighborhood', `%${neighborhood}%`);
    if (city) req = req.ilike('city', `%${city}%`);
    if (state) req = req.eq('state', state);
    if (category_id) req = req.eq('category_id', category_id);

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

  async findMe(userId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select(`
        *,
        users(id, full_name, avatar_url, phone, bio),
        categories(id, name, icon_name, color_hex),
        post_photos(id, storage_url, sort_order),
        reviews(id, rating, comment, created_at, users(id, full_name, avatar_url))
      `)
      .eq('user_id', userId)
      .eq('status', 'ativo')
      .order('created_at', { ascending: false });

    if (error) throw new NotFoundException('Perfil de prestador não encontrado');
    return data ?? [];
  }

  async findOne(id: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select(`
        *,
        users(id, full_name, avatar_url, phone, bio),
        categories(id, name, icon_name, color_hex),
        post_photos(id, storage_url, sort_order),
        reviews(id, rating, comment, created_at, users(id, full_name, avatar_url))
      `)
      .eq('id', id)
      .eq('status', 'ativo')
      .single();

    if (error || !data) throw new NotFoundException('Prestador não encontrado');
    return data;
  }

  async update(userId: string, dto: UpdateProviderDto) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .update(dto)
      .eq('user_id', userId)
      .eq('status', 'ativo')
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }

  async deactivate(userId: string) {
    const { error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .update({ status: 'inativo' })
      .eq('user_id', userId);

    if (error) throw new BadRequestException(error.message);
    return { message: 'Perfil desativado' };
  }
}
