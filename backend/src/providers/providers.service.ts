import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateProviderDto } from './dto/create-provider.dto';
import { UpdateProviderDto } from './dto/update-provider.dto';
import { SearchProvidersDto } from './dto/search-providers.dto';

const PROVIDER_SELECT = `
  *,
  users(id, full_name, avatar_url, phone, bio),
  categories(id, name, icon_name, color_hex),
  post_photos(id, storage_url, sort_order),
  reviews(id, rating, comment, created_at, users(id, full_name, avatar_url))
`;

@Injectable()
export class ProvidersService {
  private readonly logger = new Logger(ProvidersService.name);

  constructor(private supabase: SupabaseService) {}

  async create(userId: string, dto: CreateProviderDto) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('providers')
      .insert({ id: userId, ...dto })
      .select()
      .single();

    if (error) {
      this.logger.error(`Create provider failed for user ${userId}: ${error.message}`);
      throw new BadRequestException('Não foi possível criar o perfil de prestador');
    }
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

      if (rpcError) {
        this.logger.error(`providers_nearby RPC failed: ${rpcError.message}`);
        throw new BadRequestException('Não foi possível buscar prestadores próximos');
      }

      const ids: string[] = (nearby ?? []).map((r: any) => r.id);
      if (ids.length === 0) {
        return { data: [], meta: { total: 0, page, limit, total_pages: 0 } };
      }

      const { data, error } = await this.supabase
        .getAdminClient()
        .from('providers')
        .select(PROVIDER_SELECT)
        .in('id', ids);

      if (error) {
        this.logger.error(`Provider nearby select failed: ${error.message}`);
        throw new BadRequestException('Não foi possível buscar prestadores');
      }

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
      .from('providers')
      .select(PROVIDER_SELECT, { count: 'exact' })
      .eq('is_active', true)
      .order('rating_avg', { ascending: false })
      .range(from, to);

    if (neighborhood) {
      const safe = neighborhood.replace(/%/g, '\\%').replace(/_/g, '\\_');
      req = req.ilike('neighborhood', `%${safe}%`);
    }
    if (city) {
      const safe = city.replace(/%/g, '\\%').replace(/_/g, '\\_');
      req = req.ilike('city', `%${safe}%`);
    }
    if (state) req = req.eq('state', state);
    if (category_id) req = req.eq('category_id', category_id);

    const { data, error, count } = await req;
    if (error) {
      this.logger.error(`Find providers failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar os prestadores');
    }

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
      .select(PROVIDER_SELECT)
      .eq('user_id', userId)
      .eq('status', 'ativo')
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Find provider me failed for user ${userId}: ${error.message}`);
      throw new NotFoundException('Perfil de prestador não encontrado');
    }
    return data ?? [];
  }

  async findOne(id: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select(PROVIDER_SELECT)
      .eq('id', id)
      .eq('is_active', true)
      .single();

    if (error || !data) throw new NotFoundException('Prestador não encontrado');
    return data;
  }

  async update(userId: string, dto: UpdateProviderDto, token: string) {
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('posts')
      .update(dto)
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      this.logger.error(`Update provider failed for user ${userId}: ${error.message}`);
      throw new BadRequestException('Não foi possível atualizar o perfil');
    }
    return data;
  }

  async deactivate(token: string) {
    const { error } = await this.supabase
      .getUserClient(token)
      .from('posts')
      .update({ status: 'inativo' });

    if (error) {
      this.logger.error(`Deactivate provider failed: ${error.message}`);
      throw new BadRequestException('Não foi possível desativar o perfil');
    }
    return { message: 'Perfil desativado' };
  }
}
