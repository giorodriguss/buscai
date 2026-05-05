import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { UsersService } from './users.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
  };
  return qb;
}

describe('UsersService', () => {
  let service: UsersService;
  let adminClient: any;

  const mockUser = {
    id: 'user-1',
    full_name: 'João Silva',
    role: 'morador',
    bio: null,
    phone: '11999999999',
    neighborhood: 'Centro',
    city: 'São Paulo',
    state: 'SP',
    avatar_url: null,
    is_active: true,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  };

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  describe('findOne', () => {
    it('retorna perfil completo do usuário quando encontrado', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockUser }));

      const result = await service.findOne('user-1');

      expect(result).toEqual(mockUser);
      expect(adminClient.from).toHaveBeenCalledWith('users');
    });

    it('busca pelo id correto', async () => {
      const qb = makeQB({ data: mockUser });
      adminClient.from.mockReturnValue(qb);

      await service.findOne('user-1');

      expect(qb.eq).toHaveBeenCalledWith('id', 'user-1');
    });

    it('lança NotFoundException quando usuário não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'No rows found' } }),
      );

      await expect(service.findOne('inexistente')).rejects.toThrow(NotFoundException);
    });

    it('lança NotFoundException quando data é null mesmo sem erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.findOne('user-1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    const updateDto = { full_name: 'João Atualizado', city: 'Rio de Janeiro' };

    it('atualiza e retorna dados do usuário', async () => {
      const updated = { ...mockUser, ...updateDto };
      adminClient.from.mockReturnValue(makeQB({ data: updated }));

      const result = await service.update('user-1', updateDto);

      expect(result).toEqual(updated);
      expect(adminClient.from).toHaveBeenCalledWith('users');
    });

    it('atualiza apenas o usuário com o id correto', async () => {
      const qb = makeQB({ data: mockUser });
      adminClient.from.mockReturnValue(qb);

      await service.update('user-1', updateDto);

      expect(qb.eq).toHaveBeenCalledWith('id', 'user-1');
      expect(qb.update).toHaveBeenCalledWith(updateDto);
    });

    it('lança BadRequestException quando update falha no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro ao atualizar' } }));

      await expect(service.update('user-1', updateDto)).rejects.toThrow(BadRequestException);
    });

    it('aceita atualização parcial dos campos', async () => {
      const partialUpdate = { bio: 'Desenvolvedor freelancer' };
      const updated = { ...mockUser, bio: 'Desenvolvedor freelancer' };
      const qb = makeQB({ data: updated });
      adminClient.from.mockReturnValue(qb);

      const result = await service.update('user-1', partialUpdate);

      expect(result.bio).toBe('Desenvolvedor freelancer');
      expect(qb.update).toHaveBeenCalledWith(partialUpdate);
    });
  });
});
