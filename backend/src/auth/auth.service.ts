import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { SupabaseService } from '../supabase/supabase.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { VerifyPasswordDto } from './dto/verify-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private supabase: SupabaseService,
    private jwt: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const admin = this.supabase.getAdminClient();
    const normalizedCpf = dto.cpf?.replace(/\D/g, '') || null;
    const normalizedPhone = dto.phone?.replace(/\D/g, '') || null;

    const conflicts = await this.registrationConflicts(
      admin,
      dto.email,
      normalizedCpf,
      normalizedPhone,
    );
    if (Object.keys(conflicts).length > 0) {
      throw new BadRequestException({ message: conflicts });
    }

    const { data: authData, error: authError } =
      await admin.auth.admin.createUser({
        email: dto.email,
        password: dto.password,
      });

    if (authError) {
      throw new BadRequestException(
        this.authRegistrationErrorMessage(authError),
      );
    }

    const userId = authData.user.id;

    const { error: userError } = await admin.from('users').insert({
      id: userId,
      full_name: dto.full_name,
      role: dto.role,
      phone: normalizedPhone,
      cpf: normalizedCpf,
      neighborhood: dto.neighborhood ?? null,
      city: dto.city ?? null,
      state: dto.state ?? null,
    });

    if (userError) {
      await admin.auth.admin.deleteUser?.(userId);
      throw new BadRequestException(this.registrationErrorMessage(userError));
    }

    // Cria assinatura gratuita automaticamente.
    await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .insert({ user_id: userId, plan: 'free' });

    return {
      message: 'Cadastro realizado. Verifique seu e-mail para ativar a conta.',
      user: {
        id: userId,
        email: dto.email,
        full_name: dto.full_name,
        role: dto.role,
      },
    };
  }

  private registrationErrorMessage(error: { message?: string; code?: string }) {
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
    return error.message ?? 'Não foi possível concluir o cadastro.';
  }

  private async registrationConflicts(
    admin: any,
    email: string,
    cpf: string | null,
    phone: string | null,
  ) {
    const errors: Record<string, string> = {};

    const listUsers = admin.auth.admin.listUsers?.bind(admin.auth.admin);
    if (listUsers) {
      const { data } = await listUsers({ page: 1, perPage: 1000 });
      const authUsers = data?.users ?? [];
      if (
        authUsers.some(
          (user: { email?: string }) =>
            user.email?.toLowerCase() === email.toLowerCase(),
        )
      ) {
        errors.email = 'E-mail já cadastrado';
      }
    }

    const { data: users } = await admin.from('users').select('cpf, phone');
    if (Array.isArray(users)) {
      if (
        cpf != null &&
        users.some(
          (user) => (user.cpf?.toString().replace(/\D/g, '') ?? '') === cpf,
        )
      ) {
        errors.cpf = 'CPF já cadastrado';
      }
      if (
        phone != null &&
        users.some(
          (user) => (user.phone?.toString().replace(/\D/g, '') ?? '') === phone,
        )
      ) {
        errors.phone = 'Telefone já cadastrado';
      }
    }

    return errors;
  }

  private authRegistrationErrorMessage(error: { message?: string }) {
    const message = error.message?.toLowerCase() ?? '';
    if (
      message.includes('email') &&
      (message.includes('registered') ||
        message.includes('already') ||
        message.includes('cadastrado') ||
        message.includes('exists'))
    ) {
      return 'E-mail já cadastrado';
    }
    return error.message ?? 'Não foi possível concluir o cadastro.';
  }

  async login(dto: LoginDto) {
    const { data, error } = await this.supabase
      .getClient()
      .auth.signInWithPassword({ email: dto.email, password: dto.password });

    if (error) {
      const msg = error.message.toLowerCase();
      if (msg.includes('email not confirmed')) {
        throw new UnauthorizedException(
          'Confirme seu e-mail antes de fazer login',
        );
      }
      throw new UnauthorizedException('Credenciais inválidas');
    }
    if (!data.user) throw new UnauthorizedException('Credenciais inválidas');

    const { data: user } = await this.supabase
      .getAdminClient()
      .from('users')
      .select('*')
      .eq('id', data.user.id)
      .single();

    const token = this.jwt.sign({ sub: data.user.id, email: data.user.email });

    return { access_token: token, user: { ...user, email: data.user.email } };
  }

  async me(userId: string) {
    const admin = this.supabase.getAdminClient();
    const { data, error } = await admin
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) throw new UnauthorizedException();
    const { data: authData } = await admin.auth.admin.getUserById(userId);
    return { ...data, email: authData.user?.email ?? '' };
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const admin = this.supabase.getAdminClient();
    await this.verifyPassword(userId, { currentPassword: dto.currentPassword });

    const { error: updateError } = await admin.auth.admin.updateUserById(
      userId,
      {
        password: dto.newPassword,
      },
    );

    if (updateError) throw new BadRequestException(updateError.message);

    return { message: 'Senha atualizada com sucesso.' };
  }

  async verifyPassword(userId: string, dto: VerifyPasswordDto) {
    const admin = this.supabase.getAdminClient();
    const { data: userData, error: userError } =
      await admin.auth.admin.getUserById(userId);

    if (userError || !userData.user?.email) {
      throw new UnauthorizedException('Usuário não encontrado');
    }

    const { error: signInError } = await this.supabase
      .getClient()
      .auth.signInWithPassword({
        email: userData.user.email,
        password: dto.currentPassword,
      });

    if (signInError) {
      throw new UnauthorizedException('Senha atual não confere');
    }

    return { valid: true };
  }
}
