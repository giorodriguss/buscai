import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
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
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    range: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej),
  };
  return qb;
}

describe('ReviewsService', () => {
  let service: ReviewsService;
  let adminClient: any;

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReviewsService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<ReviewsService>(ReviewsService);
  });

  describe('create', () => {
    const reviewerId = 'reviewer-1';
    const dto = { post_id: 'post-1', rating: 5, comment: 'Ótimo serviço!' };

    it('cria avaliação com sucesso', async () => {
      const mockReview = { id: 'review-1', ...dto, reviewer_id: reviewerId };
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'outro-user' } }))
        .mockReturnValueOnce(makeQB({ data: mockReview }));

      const result = await service.create(reviewerId, dto, 'mock-token');

      expect(result).toEqual(mockReview);
      expect(adminClient.from).toHaveBeenCalledWith('posts');
      expect(adminClient.from).toHaveBeenCalledWith('reviews');
    });

    it('lança ForbiddenException quando revisor tenta avaliar próprio post', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { user_id: reviewerId } }));

      await expect(service.create(reviewerId, dto, 'mock-token')).rejects.toThrow(
        new ForbiddenException('Você não pode avaliar seu próprio post'),
      );
    });

    it('não bloqueia quando post não tem dono identificado', async () => {
      const mockReview = { id: 'review-1', ...dto, reviewer_id: reviewerId };
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: null }))
        .mockReturnValueOnce(makeQB({ data: mockReview }));

      const result = await service.create(reviewerId, dto, 'mock-token');

      expect(result).toEqual(mockReview);
    });

    it('lança BadRequestException quando insert de review falha', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'outro-user' } }))
        .mockReturnValueOnce(makeQB({ error: { message: 'Avaliação duplicada' } }));

      await expect(service.create(reviewerId, dto, 'mock-token')).rejects.toThrow(BadRequestException);
    });

    it('passa reviewer_id corretamente ao inserir', async () => {
      const insertQB = makeQB({ data: { id: 'review-1' } });
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'outro-user' } }))
        .mockReturnValueOnce(insertQB);

      await service.create(reviewerId, dto, 'mock-token');

      expect(insertQB.insert).toHaveBeenCalledWith(
        expect.objectContaining({ reviewer_id: reviewerId, post_id: dto.post_id, rating: dto.rating }),
      );
    });
  });

  describe('findByPost', () => {
    it('retorna avaliações paginadas do post', async () => {
      const mockReviews = [{ id: 'r1', rating: 5 }, { id: 'r2', rating: 4 }];
      adminClient.from.mockReturnValue(makeQB({ data: mockReviews, count: 2 }));

      const result = await service.findByPost('post-1', 1, 20);

      expect(result.data).toEqual(mockReviews);
      expect(result.total).toBe(2);
      expect(result.page).toBe(1);
      expect(result.limit).toBe(20);
    });

    it('calcula offset de paginação corretamente', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findByPost('post-1', 3, 10);

      expect(qb.range).toHaveBeenCalledWith(20, 29);
    });

    it('usa page=1 e limit=20 como padrão', async () => {
      const qb = makeQB({ data: [], count: 0 });
      adminClient.from.mockReturnValue(qb);

      await service.findByPost('post-1');

      expect(qb.range).toHaveBeenCalledWith(0, 19);
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro de query' } }));

      await expect(service.findByPost('post-1')).rejects.toThrow(BadRequestException);
    });
  });

  describe('delete', () => {
    it('remove avaliação quando usuário é o revisor', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { reviewer_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.delete('review-1', 'user-1');

      expect(result).toEqual({ message: 'Avaliação removida' });
    });

    it('lança NotFoundException quando avaliação não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'Not found' } }),
      );

      await expect(service.delete('inexistente', 'user-1')).rejects.toThrow(NotFoundException);
    });

    it('lança NotFoundException quando data é null mesmo sem erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.delete('review-1', 'user-1')).rejects.toThrow(NotFoundException);
    });

    it('lança ForbiddenException quando usuário não é o revisor', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { reviewer_id: 'outro-user' } }));

      await expect(service.delete('review-1', 'user-1')).rejects.toThrow(ForbiddenException);
    });

    it('chama delete com o id correto da avaliação', async () => {
      const deleteQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { reviewer_id: 'user-1' } }))
        .mockReturnValueOnce(deleteQB);

      await service.delete('review-1', 'user-1');

      expect(deleteQB.delete).toHaveBeenCalled();
      expect(deleteQB.eq).toHaveBeenCalledWith('id', 'review-1');
    });
  });
});
