import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException } from '@nestjs/common';
import { TagsService } from './tags.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    order: jest.fn().mockResolvedValue(value),
  };
  return qb;
}

describe('TagsService', () => {
  let service: TagsService;
  let adminClient: any;

  const mockTags = [
    { id: 'tag-1', name: 'Disponível', slug: 'disponivel' },
    { id: 'tag-2', name: 'Urgente', slug: 'urgente' },
  ];

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TagsService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<TagsService>(TagsService);
  });

  describe('findAll', () => {
    it('retorna lista de todas as tags', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockTags }));

      const result = await service.findAll();

      expect(result).toEqual(mockTags);
      expect(adminClient.from).toHaveBeenCalledWith('tags');
    });

    it('ordena tags por nome', async () => {
      const qb = makeQB({ data: mockTags });
      adminClient.from.mockReturnValue(qb);

      await service.findAll();

      expect(qb.order).toHaveBeenCalledWith('name');
    });

    it('seleciona apenas campos id, name, slug', async () => {
      const qb = makeQB({ data: mockTags });
      adminClient.from.mockReturnValue(qb);

      await service.findAll();

      expect(qb.select).toHaveBeenCalledWith('id, name, slug');
    });

    it('retorna array vazio quando não há tags', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [] }));

      const result = await service.findAll();

      expect(result).toEqual([]);
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Tabela não encontrada' } }));

      await expect(service.findAll()).rejects.toThrow(BadRequestException);
    });
  });
});
