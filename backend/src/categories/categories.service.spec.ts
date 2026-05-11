import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    order: jest.fn().mockResolvedValue(value),
  };
  return qb;
}

describe('CategoriesService', () => {
  let service: CategoriesService;
  let adminClient: any;

  const mockCategories = [
    { id: 'cat-1', name: 'Limpeza', slug: 'limpeza', icon_name: 'broom', color_hex: '#00FF00' },
    { id: 'cat-2', name: 'Manutenção', slug: 'manutencao', icon_name: 'wrench', color_hex: '#FF0000' },
  ];

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CategoriesService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<CategoriesService>(CategoriesService);
  });

  describe('findAll', () => {
    it('retorna lista de categorias ativas', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockCategories }));

      const result = await service.findAll();

      expect(result).toEqual(mockCategories);
      expect(adminClient.from).toHaveBeenCalledWith('categories');
    });

    it('filtra apenas categorias ativas via eq', async () => {
      const qb = makeQB({ data: mockCategories });
      adminClient.from.mockReturnValue(qb);

      await service.findAll();

      expect(qb.eq).toHaveBeenCalledWith('is_active', true);
    });

    it('ordena resultados por nome', async () => {
      const qb = makeQB({ data: mockCategories });
      adminClient.from.mockReturnValue(qb);

      await service.findAll();

      expect(qb.order).toHaveBeenCalledWith('name');
    });

    it('seleciona apenas os campos necessários', async () => {
      const qb = makeQB({ data: mockCategories });
      adminClient.from.mockReturnValue(qb);

      await service.findAll();

      expect(qb.select).toHaveBeenCalledWith('id, name, slug, icon_name, color_hex');
    });

    it('retorna array vazio quando não há categorias ativas', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [] }));

      const result = await service.findAll();

      expect(result).toEqual([]);
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro de conexão' } }));

      await expect(service.findAll()).rejects.toThrow(BadRequestException);
    });
  });
});
