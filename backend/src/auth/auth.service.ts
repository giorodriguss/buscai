import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { SupabaseService } from '../supabase/supabase.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private supabase: SupabaseService,
    private jwt: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const { data: authData, error: authError } = await this.supabase
      .getAdminClient()
      .auth.admin.createUser({
        email: dto.email,
        password: dto.password,
        email_confirm: true,
      });

    if (authError) throw new BadRequestException(authError.message);

    const userId = authData.user.id;

    const { error: userError } = await this.supabase
      .getAdminClient()
      .from('users')
      .insert({
        id: userId,
        full_name: dto.full_name,
        role: dto.role,
        phone: dto.phone ?? null,
        neighborhood: dto.neighborhood ?? null,
        city: dto.city ?? null,
        state: dto.state ?? null,
      });

    if (userError) throw new BadRequestException(userError.message);

    // Cria assinatura gratuita automaticamente
    await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .insert({ user_id: userId, plan: 'free' });

    const token = this.jwt.sign({ sub: userId, email: dto.email });

    return {
      access_token: token,
      user: { id: userId, email: dto.email, full_name: dto.full_name, role: dto.role },
    };
  }

  async login(dto: LoginDto) {
    const { data, error } = await this.supabase
      .getClient()
      .auth.signInWithPassword({ email: dto.email, password: dto.password });

    if (error || !data.user) throw new UnauthorizedException('Credenciais inválidas');

    const { data: user } = await this.supabase
      .getAdminClient()
      .from('users')
      .select('*')
      .eq('id', data.user.id)
      .single();

    const token = this.jwt.sign({ sub: data.user.id, email: data.user.email });

    return { access_token: token, user };
  }

  async me(userId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) throw new UnauthorizedException();
    return data;
  }
}
