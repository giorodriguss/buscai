import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuthService } from './auth.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej),
  };
  return qb;
}

describe('AuthService', () => {
  let service: AuthService;
  let adminClient: any;
  let anonClient: any;
  let jwtSign: jest.Mock;

  beforeEach(async () => {
    adminClient = {
      from: jest.fn(),
      auth: { admin: { createUser: jest.fn() } },
    };
    anonClient = {
      auth: { signInWithPassword: jest.fn() },
    };
    jwtSign = jest.fn().mockReturnValue('mock-token');

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: SupabaseService,
          useValue: {
            getAdminClient: jest.fn().mockReturnValue(adminClient),
            getClient: jest.fn().mockReturnValue(anonClient),
          },
        },
        {
          provide: JwtService,
          useValue: { sign: jwtSign },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  describe('register', () => {
    const dto = {
      email: 'joao@test.com',
      password: 'senha123',
      full_name: 'João Silva',
      role: 'morador' as const,
    };

    it('cria usuário e retorna mensagem de verificação de e-mail', async () => {
      adminClient.auth.admin.createUser.mockResolvedValue({
        data: { user: { id: 'uid-1' } },
        error: null,
      });
      adminClient.from
        .mockReturnValueOnce(makeQB())
        .mockReturnValueOnce(makeQB());

      const result = await service.register(dto);

      expect(result.message).toContain('Verifique seu e-mail');
      expect(result.user).toMatchObject({ id: 'uid-1', email: dto.email, full_name: dto.full_name });
      expect(jwtSign).not.toHaveBeenCalled();
    });

    it('cria assinatura free automaticamente após o cadastro', async () => {
      adminClient.auth.admin.createUser.mockResolvedValue({
        data: { user: { id: 'uid-1' } },
        error: null,
      });
      adminClient.from
        .mockReturnValueOnce(makeQB())
        .mockReturnValueOnce(makeQB());

      await service.register(dto);

      expect(adminClient.from).toHaveBeenCalledWith('subscriptions');
      const subsQB = adminClient.from.mock.results[1].value;
      expect(subsQB.insert).toHaveBeenCalledWith({ user_id: 'uid-1', plan: 'free' });
    });

    it('lança BadRequestException quando Supabase Auth retorna erro', async () => {
      adminClient.auth.admin.createUser.mockResolvedValue({
        data: null,
        error: { message: 'Email já cadastrado' },
      });

      await expect(service.register(dto)).rejects.toThrow(BadRequestException);
    });

    it('lança BadRequestException quando insert na tabela users falha', async () => {
      adminClient.auth.admin.createUser.mockResolvedValue({
        data: { user: { id: 'uid-1' } },
        error: null,
      });
      adminClient.from.mockReturnValueOnce(makeQB({ error: { message: 'FK violation' } }));

      await expect(service.register(dto)).rejects.toThrow(BadRequestException);
    });

    it('passa os campos opcionais corretamente ao inserir no banco', async () => {
      const fullDto = { ...dto, phone: '11999999999', neighborhood: 'Centro', city: 'SP', state: 'SP' };
      adminClient.auth.admin.createUser.mockResolvedValue({
        data: { user: { id: 'uid-1' } },
        error: null,
      });
      const usersQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(usersQB)
        .mockReturnValueOnce(makeQB());

      await service.register(fullDto);

      expect(usersQB.insert).toHaveBeenCalledWith(
        expect.objectContaining({ phone: '11999999999', neighborhood: 'Centro' }),
      );
    });
  });

  describe('login', () => {
    const dto = { email: 'joao@test.com', password: 'senha123' };
    const mockUser = { id: 'uid-1', full_name: 'João', role: 'morador' };

    it('retorna access_token e dados do usuário com credenciais válidas', async () => {
      anonClient.auth.signInWithPassword.mockResolvedValue({
        data: { user: { id: 'uid-1', email: dto.email } },
        error: null,
      });
      adminClient.from.mockReturnValue(makeQB({ data: mockUser }));

      const result = await service.login(dto);

      expect(result.access_token).toBe('mock-token');
      expect(result.user).toEqual(mockUser);
    });

    it('lança UnauthorizedException com credenciais inválidas', async () => {
      anonClient.auth.signInWithPassword.mockResolvedValue({
        data: { user: null },
        error: { message: 'Invalid credentials' },
      });

      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
    });

    it('lança UnauthorizedException quando user é null mesmo sem erro explícito', async () => {
      anonClient.auth.signInWithPassword.mockResolvedValue({
        data: { user: null },
        error: null,
      });

      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('me', () => {
    it('retorna perfil do usuário autenticado', async () => {
      const mockUser = { id: 'uid-1', full_name: 'João' };
      adminClient.from.mockReturnValue(makeQB({ data: mockUser }));

      const result = await service.me('uid-1');

      expect(result).toEqual(mockUser);
      expect(adminClient.from).toHaveBeenCalledWith('users');
    });

    it('lança UnauthorizedException quando query retorna erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Not found' } }));

      await expect(service.me('invalid-id')).rejects.toThrow(UnauthorizedException);
    });
  });
});
