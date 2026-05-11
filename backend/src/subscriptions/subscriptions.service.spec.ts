import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
  };
  return qb;
}

describe('SubscriptionsService', () => {
  let service: SubscriptionsService;
  let adminClient: any;

  const mockSubscription = {
    id: 'sub-1',
    plan: 'free',
    status: 'active',
    max_posts: 1,
    max_photos: 3,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  };

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SubscriptionsService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<SubscriptionsService>(SubscriptionsService);
  });

  describe('findByUser', () => {
    it('retorna assinatura do usuário quando encontrada', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockSubscription }));

      const result = await service.findByUser('user-1');

      expect(result).toEqual(mockSubscription);
      expect(adminClient.from).toHaveBeenCalledWith('subscriptions');
    });

    it('busca assinatura pelo user_id correto', async () => {
      const qb = makeQB({ data: mockSubscription });
      adminClient.from.mockReturnValue(qb);

      await service.findByUser('user-42');

      expect(qb.eq).toHaveBeenCalledWith('user_id', 'user-42');
    });

    it('seleciona apenas os campos necessários', async () => {
      const qb = makeQB({ data: mockSubscription });
      adminClient.from.mockReturnValue(qb);

      await service.findByUser('user-1');

      expect(qb.select).toHaveBeenCalledWith(
        'id, plan, status, max_posts, max_photos, created_at, updated_at',
      );
    });

    it('lança NotFoundException quando assinatura não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'No rows found' } }),
      );

      await expect(service.findByUser('user-sem-assinatura')).rejects.toThrow(NotFoundException);
    });

    it('lança NotFoundException quando data é null mesmo sem erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.findByUser('user-1')).rejects.toThrow(NotFoundException);
    });

    it('retorna todos os campos do plano premium', async () => {
      const premiumSub = { ...mockSubscription, plan: 'premium', max_posts: 10, max_photos: 10 };
      adminClient.from.mockReturnValue(makeQB({ data: premiumSub }));

      const result = await service.findByUser('user-1');

      expect(result.plan).toBe('premium');
      expect(result.max_posts).toBe(10);
    });
  });
});
