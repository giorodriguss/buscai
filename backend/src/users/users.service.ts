import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
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

  async update(id: string, dto: UpdateUserDto) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('users')
      .update(dto)
      .eq('id', id)
      .select('id, full_name, role, bio, phone, neighborhood, city, state, avatar_url, is_active, updated_at')
      .single();

    if (error) throw new BadRequestException(error.message);
    return data;
  }
}
