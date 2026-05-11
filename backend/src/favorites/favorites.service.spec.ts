import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException } from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej as any),
  };
  return qb;
}

describe('FavoritesService', () => {
  let service: FavoritesService;
  let adminClient: any;

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FavoritesService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<FavoritesService>(FavoritesService);
  });

  describe('add', () => {
    it('adiciona post aos favoritos com sucesso', async () => {
      const mockFav = { id: 'fav-1', user_id: 'user-1', post_id: 'post-1' };
      adminClient.from.mockReturnValue(makeQB({ data: mockFav }));

      const result = await service.add('user-1', 'post-1');

      expect(result).toEqual(mockFav);
      expect(adminClient.from).toHaveBeenCalledWith('favorites');
    });

    it('insere user_id e post_id corretamente', async () => {
      const qb = makeQB({ data: { id: 'fav-1' } });
      adminClient.from.mockReturnValue(qb);

      await service.add('user-1', 'post-1');

      expect(qb.insert).toHaveBeenCalledWith({ user_id: 'user-1', post_id: 'post-1' });
    });

    it('lança BadRequestException quando insert falha', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Favorito duplicado' } }));

      await expect(service.add('user-1', 'post-1')).rejects.toThrow(BadRequestException);
    });
  });

  describe('remove', () => {
    it('remove favorito com sucesso', async () => {
      adminClient.from.mockReturnValue(makeQB());

      const result = await service.remove('user-1', 'post-1');

      expect(result).toEqual({ message: 'Favorito removido' });
    });

    it('filtra por user_id e post_id ao deletar', async () => {
      const qb = makeQB();
      adminClient.from.mockReturnValue(qb);

      await service.remove('user-1', 'post-1');

      expect(qb.eq).toHaveBeenCalledWith('user_id', 'user-1');
      expect(qb.eq).toHaveBeenCalledWith('post_id', 'post-1');
    });

    it('lança BadRequestException quando delete falha', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro ao deletar' } }));

      await expect(service.remove('user-1', 'post-1')).rejects.toThrow(BadRequestException);
    });
  });

  describe('findByUser', () => {
    it('retorna lista de favoritos do usuário', async () => {
      const favs = [
        {
          id: 'fav-1',
          created_at: '2024-01-01',
          posts: { id: 'p1', whatsapp: '11999999999', title: 'Encanador' },
        },
      ];
      adminClient.from.mockReturnValue(makeQB({ data: favs }));

      const result = await service.findByUser('user-1');

      expect(result).toHaveLength(1);
      expect(adminClient.from).toHaveBeenCalledWith('favorites');
    });

    it('adiciona whatsapp_link nos posts dos favoritos', async () => {
      const favs = [{ id: 'fav-1', posts: { whatsapp: '11988887777', title: 'Pintor' } }];
      adminClient.from.mockReturnValue(makeQB({ data: favs }));

      const result = await service.findByUser('user-1');

      expect(result![0].posts.whatsapp_link).toBe('https://wa.me/5511988887777');
    });

    it('define whatsapp_link como null quando post não tem whatsapp', async () => {
      const favs = [{ id: 'fav-1', posts: { whatsapp: null, title: 'Pintor' } }];
      adminClient.from.mockReturnValue(makeQB({ data: favs }));

      const result = await service.findByUser('user-1');

      expect(result![0].posts.whatsapp_link).toBeNull();
    });

    it('define post como null quando favorito não tem post associado', async () => {
      const favs = [{ id: 'fav-1', posts: null }];
      adminClient.from.mockReturnValue(makeQB({ data: favs }));

      const result = await service.findByUser('user-1');

      expect(result![0].posts).toBeNull();
    });

    it('filtra pelo user_id correto', async () => {
      const qb = makeQB({ data: [] });
      adminClient.from.mockReturnValue(qb);

      await service.findByUser('user-42');

      expect(qb.eq).toHaveBeenCalledWith('user_id', 'user-42');
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro de query' } }));

      await expect(service.findByUser('user-1')).rejects.toThrow(BadRequestException);
    });
  });
});
