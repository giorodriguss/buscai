import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { AdsService } from './ads.service';
import { SupabaseService } from '../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej as any),
  };
  return qb;
}

describe('AdsService', () => {
  let service: AdsService;
  let adminClient: any;

  const mockAds = [
    { id: 'ad-1', title: 'Anúncio 1', image_url: 'img.jpg', link_url: 'https://link.com', impressions: 10, clicks: 2 },
    { id: 'ad-2', title: 'Anúncio 2', image_url: 'img2.jpg', link_url: 'https://link2.com', impressions: 5, clicks: 1 },
  ];

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdsService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<AdsService>(AdsService);
  });

  describe('findActive', () => {
    it('retorna lista de anúncios ativos', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: mockAds }));

      const result = await service.findActive();

      expect(result).toEqual(mockAds);
      expect(adminClient.from).toHaveBeenCalledWith('ads');
    });

    it('filtra apenas anúncios com status ativo', async () => {
      const qb = makeQB({ data: mockAds });
      adminClient.from.mockReturnValue(qb);

      await service.findActive();

      expect(qb.eq).toHaveBeenCalledWith('status', 'ativo');
    });

    it('ordena por data de criação decrescente', async () => {
      const qb = makeQB({ data: mockAds });
      adminClient.from.mockReturnValue(qb);

      await service.findActive();

      expect(qb.order).toHaveBeenCalledWith('created_at', { ascending: false });
    });

    it('retorna lista vazia quando não há anúncios ativos', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: [] }));

      const result = await service.findActive();

      expect(result).toEqual([]);
    });

    it('lança BadRequestException em caso de erro no banco', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Erro de conexão' } }));

      await expect(service.findActive()).rejects.toThrow(BadRequestException);
    });
  });

  describe('trackImpression', () => {
    it('incrementa impressões e retorna { ok: true }', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { impressions: 10 } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.trackImpression('ad-1');

      expect(result).toEqual({ ok: true });
    });

    it('incrementa o valor atual de impressões em 1', async () => {
      const updateQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { impressions: 5 } }))
        .mockReturnValueOnce(updateQB);

      await service.trackImpression('ad-1');

      expect(updateQB.update).toHaveBeenCalledWith({ impressions: 6 });
    });

    it('incrementa de 0 quando impressions é null', async () => {
      const updateQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { impressions: null } }))
        .mockReturnValueOnce(updateQB);

      await service.trackImpression('ad-1');

      expect(updateQB.update).toHaveBeenCalledWith({ impressions: 1 });
    });

    it('atualiza o anúncio correto', async () => {
      const updateQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { impressions: 3 } }))
        .mockReturnValueOnce(updateQB);

      await service.trackImpression('ad-1');

      expect(updateQB.eq).toHaveBeenCalledWith('id', 'ad-1');
    });

    it('lança NotFoundException quando anúncio não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'Not found' } }),
      );

      await expect(service.trackImpression('inexistente')).rejects.toThrow(NotFoundException);
    });

    it('lança NotFoundException quando data é null mesmo sem erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.trackImpression('ad-1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('trackClick', () => {
    it('incrementa cliques e retorna { ok: true }', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { clicks: 3 } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.trackClick('ad-1');

      expect(result).toEqual({ ok: true });
    });

    it('incrementa o valor atual de cliques em 1', async () => {
      const updateQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { clicks: 8 } }))
        .mockReturnValueOnce(updateQB);

      await service.trackClick('ad-1');

      expect(updateQB.update).toHaveBeenCalledWith({ clicks: 9 });
    });

    it('incrementa de 0 quando clicks é null', async () => {
      const updateQB = makeQB();
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { clicks: null } }))
        .mockReturnValueOnce(updateQB);

      await service.trackClick('ad-1');

      expect(updateQB.update).toHaveBeenCalledWith({ clicks: 1 });
    });

    it('lança NotFoundException quando anúncio não existe', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: null, error: { message: 'Not found' } }),
      );

      await expect(service.trackClick('inexistente')).rejects.toThrow(NotFoundException);
    });

    it('lança NotFoundException quando data é null mesmo sem erro', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.trackClick('ad-1')).rejects.toThrow(NotFoundException);
    });
  });
});
