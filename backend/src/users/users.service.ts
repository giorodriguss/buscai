import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(private supabase: SupabaseService) {}

  async findOne(id: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('users')
      .select('id, full_name, role, bio, phone, neighborhood, city, state, avatar_url, is_active, created_at, updated_at')
      .eq('id', id)
      .single();

    if (error || !data) throw new NotFoundException('Usuário não encontrado');
    return data;
  }

  async update(id: string, dto: UpdateUserDto, token: string) {
    // user client aplica RLS: só atualiza se auth.uid() = id
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('users')
      .update(dto)
      .eq('id', id)
      .select('id, full_name, role, bio, phone, neighborhood, city, state, avatar_url, is_active, updated_at')
      .single();

    if (error) {
      this.logger.error(`Update user ${id} failed: ${error.message}`);
      throw new BadRequestException('Não foi possível atualizar o usuário');
    }
    return data;
  }
}
