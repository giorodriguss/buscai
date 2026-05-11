import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PostsService } from './posts.service';
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
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    ilike: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    range: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej as any),
  };
  return qb;
}

describe('PostsService', () => {
  let service: PostsService;
  let adminClient: any;

  const mockPost = {
    id: 'post-1',
    title: 'Encanador',
    whatsapp: '11999999999',
    whatsapp_link: 'https://wa.me/5511999999999',
    neighborhood: 'Centro',
    city: 'São Paulo',
    state: 'SP',
    views_count: 0,
    status: 'ativo',
  };

  const createDto = {
    title: 'Encanador',
    category_id: 'cat-uuid-1',
    whatsapp: '11999999999',
  };

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PostsService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<PostsService>(PostsService);
  });

  describe('create', () => {
    it('cria post dentro do limite de assinatura', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { max_posts: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 2 }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }));

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      const result = await service.create('user-1', createDto);

      expect(result).toEqual(mockPost);
      expect(adminClient.from).toHaveBeenCalledWith('posts');
    });

    it('usa max_posts = 1 quando não há assinatura cadastrada', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: null }))
        .mockReturnValueOnce(makeQB({ count: 1 }));

      await expect(service.create('user-1', createDto)).rejects.toThrow(BadRequestException);
    });

    it('lança BadRequestException quando limite de posts atingido', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { max_posts: 3 } }))
        .mockReturnValueOnce(makeQB({ count: 3 }));

      await expect(service.create('user-1', createDto)).rejects.toThrow(
        new BadRequestException('Seu plano permite no máximo 3 post(s) ativo(s)'),
      );
    });

    it('lança BadRequestException quando insert no banco falha', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { max_posts: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 0 }))
        .mockReturnValueOnce(makeQB({ error: { message: 'Violação de FK' } }));

      await expect(service.create('user-1', createDto)).rejects.toThrow(BadRequestException);
    });

    it('insere tags na tabela post_tags quando tag_ids fornecido', async () => {
      const tagsQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { max_posts: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 0 }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }))
        .mockReturnValueOnce(tagsQB);

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      await service.create('user-1', { ...createDto, tag_ids: ['tag-uuid-1', 'tag-uuid-2'] });

      expect(adminClient.from).toHaveBeenCalledWith('post_tags');
      expect(tagsQB.insert).toHaveBeenCalledWith([
        { post_id: 'post-1', tag_id: 'tag-uuid-1' },
        { post_id: 'post-1', tag_id: 'tag-uuid-2' },
      ]);
    });

    it('não insere post_tags quando tag_ids não fornecido', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { max_posts: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 0 }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }));

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      await service.create('user-1', createDto);

      expect(adminClient.from).not.toHaveBeenCalledWith('post_tags');
    });
  });

  describe('findAll', () => {
    it('retorna lista paginada de posts com metadados', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [mockPost], count: 1 }));

      const result = await service.findAll({ page: 1, limit: 20 });

      expect(result.total).toBe(1);
      expect(result.page).toBe(1);
      expect(result.limit).toBe(20);
      expect(result.data).toHaveLength(1);
    });

    it('adiciona whatsapp_link em todos os posts retornados', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: [{ id: 'p1', whatsapp: '11988887777' }], count: 1 }),
      );

      const result = await service.findAll({});

      expect(result.data![0].whatsapp_link).toBe('https://wa.me/5511988887777');
    });

    it('aplica filtro de busca por texto no título', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ q: 'encanador' });

      expect(qb.ilike).toHaveBeenCalledWith('title', '%encanador%');
    });

    it('aplica filtro de categoria', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ category_id: 'cat-uuid-1' });

      expect(qb.eq).toHaveBeenCalledWith('category_id', 'cat-uuid-1');
    });

    it('aplica filtro de bairro', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ neighborhood: 'Pinheiros' });

      expect(qb.ilike).toHaveBeenCalledWith('neighborhood', '%Pinheiros%');
    });

    it('aplica filtro de cidade', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ city: 'Campinas' });

      expect(qb.ilike).toHaveBeenCalledWith('city', '%Campinas%');
    });

    it('aplica filtro de estado', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findAll({ state: 'SP' });

      expect(qb.eq).toHaveBeenCalledWith('state', 'SP');
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Query inválida' } }));

      await expect(service.findAll({})).rejects.toThrow(BadRequestException);
    });
  });

  describe('findOne', () => {
    it('retorna post com whatsapp_link quando encontrado', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { ...mockPost, views_count: 3 } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.findOne('post-1');

      expect(result.id).toBe('post-1');
      expect(result.whatsapp_link).toBe('https://wa.me/5511999999999');
    });

    it('incrementa views_count ao buscar o post', async () => {
      const updateQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { ...mockPost, views_count: 5 } }))
        .mockReturnValueOnce(updateQB);

      await service.findOne('post-1');

      expect(updateQB.update).toHaveBeenCalledWith({ views_count: 6 });
    });

    it('define whatsapp_link como null quando whatsapp está vazio', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { ...mockPost, whatsapp: null } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.findOne('post-1');

      expect(result.whatsapp_link).toBeNull();
    });

    it('lança NotFoundException quando post não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'No rows found' } }),
      );

      await expect(service.findOne('inexistente')).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    const updateDto = { title: 'Encanador Expert' };

    it('atualiza post quando usuário é dono', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }));

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      const result = await service.update('post-1', updateDto, 'mock-token');

      expect(result).toEqual(mockPost);
    });

    it('lança ForbiddenException quando usuário não é dono', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { user_id: 'outro-user' } }));

      await expect(service.update('post-1', updateDto, 'mock-token')).rejects.toThrow(ForbiddenException);
    });

    it('lança NotFoundException quando post não existe', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.update('post-1', updateDto, 'mock-token')).rejects.toThrow(NotFoundException);
    });

    it('lança BadRequestException quando update no banco falha', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ error: { message: 'Erro de constraint' } }));

      await expect(service.update('post-1', updateDto, 'mock-token')).rejects.toThrow(BadRequestException);
    });

    it('substitui tags existentes quando tag_ids fornecido', async () => {
      const deleteTagsQB = makeQB();
      const insertTagsQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }))
        .mockReturnValueOnce(deleteTagsQB)
        .mockReturnValueOnce(insertTagsQB);

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      await service.update('post-1', { tag_ids: ['tag-uuid-1'] }, 'mock-token');

      expect(deleteTagsQB.delete).toHaveBeenCalled();
      expect(deleteTagsQB.eq).toHaveBeenCalledWith('post_id', 'post-1');
      expect(insertTagsQB.insert).toHaveBeenCalledWith([
        { post_id: 'post-1', tag_id: 'tag-uuid-1' },
      ]);
    });

    it('apenas deleta tags quando tag_ids for array vazio', async () => {
      const deleteTagsQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }))
        .mockReturnValueOnce(deleteTagsQB);

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      await service.update('post-1', { tag_ids: [] }, 'mock-token');

      expect(deleteTagsQB.delete).toHaveBeenCalled();
      expect(adminClient.from).toHaveBeenCalledTimes(3);
    });

    it('não altera tags quando tag_ids não for fornecido', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { id: 'post-1' } }));

      jest.spyOn(service, 'findOne').mockResolvedValue(mockPost as any);

      await service.update('post-1', { title: 'Novo título' }, 'mock-token');

      expect(adminClient.from).not.toHaveBeenCalledWith('post_tags');
    });
  });

  describe('remove', () => {
    it('remove post quando usuário é dono', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.remove('post-1', 'user-1');

      expect(result).toEqual({ message: 'Post removido' });
    });

    it('lança ForbiddenException quando usuário não é dono', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { user_id: 'outro-user' } }));

      await expect(service.remove('post-1', 'user-1')).rejects.toThrow(ForbiddenException);
    });

    it('lança NotFoundException quando post não existe', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.remove('post-1', 'user-1')).rejects.toThrow(NotFoundException);
    });

    it('lança BadRequestException quando delete falha no banco', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ error: { message: 'FK constraint' } }));

      await expect(service.remove('post-1', 'user-1')).rejects.toThrow(BadRequestException);
    });
  });

  describe('findByUser', () => {
    it('retorna posts do usuário com whatsapp_link', async () => {
      const userPosts = [{ id: 'p1', whatsapp: '11999991111' }, { id: 'p2', whatsapp: null }];
      adminClient.from.mockReturnValue(makeQB({ data: userPosts }));

      const result = await service.findByUser('user-1');

      expect(result![0].whatsapp_link).toBe('https://wa.me/5511999991111');
      expect(result![1].whatsapp_link).toBeNull();
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro' } }));

      await expect(service.findByUser('user-1')).rejects.toThrow(BadRequestException);
    });
  });
});
