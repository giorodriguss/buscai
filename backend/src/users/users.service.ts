import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
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
      .select(
        'id, full_name, role, bio, phone, cpf, neighborhood, city, state, avatar_url, is_active, created_at, updated_at',
      )
      .eq('id', id)
      .single();

    if (error || !data) throw new NotFoundException('Usuário não encontrado');
    return data;
  }

  async update(id: string, dto: UpdateUserDto, token: string) {
    const normalizedPhone = dto.phone?.replace(/\D/g, '');
    if (normalizedPhone != null) {
      const { data: users } = await this.supabase
        .getAdminClient()
        .from('users')
        .select('id, phone');
      if (
        Array.isArray(users) &&
        users.some(
          (user) =>
            user.id !== id &&
            (user.phone?.toString().replace(/\D/g, '') ?? '') ===
              normalizedPhone,
        )
      ) {
        throw new BadRequestException({
          message: { phone: 'Telefone já cadastrado' },
        });
      }
    }

    const payload = {
      ...dto,
      ...(dto.cpf != null ? { cpf: dto.cpf.replace(/\D/g, '') } : {}),
      ...(normalizedPhone != null ? { phone: normalizedPhone } : {}),
    };
    // User client aplica RLS: só atualiza se auth.uid() = id.
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('users')
      .update(payload)
      .eq('id', id)
      .select(
        'id, full_name, role, bio, phone, cpf, neighborhood, city, state, avatar_url, is_active, updated_at',
      )
      .single();

    if (error) {
      this.logger.error(`Update user ${id} failed: ${error.message}`);
      throw new BadRequestException(this.updateErrorMessage(error));
    }
    return data;
  }

  private updateErrorMessage(error: { message?: string; code?: string }) {
    const message = error.message?.toLowerCase() ?? '';
    if (
      error.code === '23505' ||
      (message.includes('cpf') &&
        (message.includes('duplicate') ||
          message.includes('unique') ||
          message.includes('duplic')))
    ) {
      return 'CPF já cadastrado';
    }
    if (
      message.includes('cpf') &&
      (message.includes('check') ||
        message.includes('length') ||
        message.includes('constraint'))
    ) {
      return 'CPF inválido. Use 11 dígitos.';
    }
    return 'Não foi possível atualizar o usuário';
  }
}
