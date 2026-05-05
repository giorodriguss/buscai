import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ProvidersService } from './providers.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any; count?: any } = {}) {
  const value = {
    data: resolved.data ?? null,
    error: resolved.error ?? null,
    count: resolved.count ?? null,
  };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    ilike: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    range: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej),
  };
  return qb;
}

describe('ProvidersService', () => {
  let service: ProvidersService;
  let adminClient: any;

  const mockProvider = {
    id: 'user-1',
    description: 'Encanador experiente',
    whatsapp: '11999999999',
    neighborhood: 'Centro',
    is_active: true,
    rating_avg: 4.5,
    rating_count: 10,
  };

  const createDto = {
    description: 'Encanador experiente',
    category_id: 'cat-uuid-1',
    whatsapp: '11999999999',
    neighborhood: 'Centro',
  };

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProvidersService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<ProvidersService>(ProvidersService);
  });

  describe('create', () => {
    it('cria perfil de prestador com sucesso', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockProvider }));

      const result = await service.create('user-1', createDto);

      expect(result).toEqual(mockProvider);
      expect(adminClient.from).toHaveBeenCalledWith('providers');
    });

    it('usa o userId como id do prestador', async () => {
      const insertQB = makeQB({ data: mockProvider });
      adminClient.from.mockReturnValue(insertQB);

      await service.create('user-1', createDto);

      expect(insertQB.insert).toHaveBeenCalledWith(
        expect.objectContaining({ id: 'user-1' }),
      );
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Perfil já existe' } }));

      await expect(service.create('user-1', createDto)).rejects.toThrow(BadRequestException);
    });
  });

  describe('findAll', () => {
    it('retorna lista paginada de prestadores com metadados', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [mockProvider], count: 1 }));

      const result = await service.findAll({ page: 1, limit: 10 });

      expect(result.data).toHaveLength(1);
      expect(result.meta.total).toBe(1);
      expect(result.meta.page).toBe(1);
      expect(result.meta.limit).toBe(10);
      expect(result.meta.total_pages).toBe(1);
    });

    it('calcula total_pages corretamente', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [], count: 25 }));

      const result = await service.findAll({ page: 1, limit: 10 });

      expect(result.meta.total_pages).toBe(3);
    });

    it('aplica filtro de bairro via ilike', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ neighborhood: 'Pinheiros' });

      expect(qb.ilike).toHaveBeenCalledWith('neighborhood', '%Pinheiros%');
    });

    it('aplica filtro de categoria via eq', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ category_id: 'cat-uuid-1' });

      expect(qb.eq).toHaveBeenCalledWith('category_id', 'cat-uuid-1');
    });

    it('não aplica filtros quando não fornecidos', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({});

      expect(qb.ilike).not.toHaveBeenCalled();
    });

    it('retorna meta.total = 0 quando count é null', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [], count: null }));

      const result = await service.findAll({});

      expect(result.meta.total).toBe(0);
      expect(result.meta.total_pages).toBe(0);
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro de conexão' } }));

      await expect(service.findAll({})).rejects.toThrow(BadRequestException);
    });
  });

  describe('findOne', () => {
    it('retorna prestador ativo quando encontrado', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockProvider }));

      const result = await service.findOne('user-1');

      expect(result).toEqual(mockProvider);
      expect(adminClient.from).toHaveBeenCalledWith('providers');
    });

    it('filtra apenas prestadores ativos', async () => {
      const qb = makeQB({ data: mockProvider });
      adminClient.from.mockReturnValue(qb);

      await service.findOne('user-1');

      expect(qb.eq).toHaveBeenCalledWith('is_active', true);
    });

    it('lança NotFoundException quando prestador não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'Not found' } }),
      );

      await expect(service.findOne('inexistente')).rejects.toThrow(NotFoundException);
    });

    it('lança NotFoundException quando data é null mesmo sem erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.findOne('user-1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('atualiza dados do prestador com sucesso', async () => {
      const updated = { ...mockProvider, description: 'Nova descrição atualizada' };
      adminClient.from.mockReturnValue(makeQB({ data: updated }));

      const result = await service.update('user-1', { description: 'Nova descrição atualizada' });

      expect(result).toEqual(updated);
    });

    it('atualiza apenas o prestador do usuário autenticado', async () => {
      const qb = makeQB({ data: mockProvider });
      adminClient.from.mockReturnValue(qb);

      await service.update('user-1', { description: 'Nova' });

      expect(qb.eq).toHaveBeenCalledWith('id', 'user-1');
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Registro não encontrado' } }));

      await expect(service.update('user-1', { description: 'X' })).rejects.toThrow(BadRequestException);
    });
  });

  describe('deactivate', () => {
    it('desativa perfil do prestador com sucesso', async () => {
      adminClient.from.mockReturnValue(makeQB());

      const result = await service.deactivate('user-1');

      expect(result).toEqual({ message: 'Perfil desativado' });
    });

    it('envia is_active = false ao atualizar', async () => {
      const qb = makeQB();
      adminClient.from.mockReturnValue(qb);

      await service.deactivate('user-1');

      expect(qb.update).toHaveBeenCalledWith({ is_active: false });
      expect(qb.eq).toHaveBeenCalledWith('id', 'user-1');
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro ao desativar' } }));

      await expect(service.deactivate('user-1')).rejects.toThrow(BadRequestException);
    });
  });
});
