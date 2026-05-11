import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException } from '@nestjs/common';
import { ArgumentMetadata } from '@nestjs/common';
import { ValidCategoryPipe } from './valid-category.pipe';
import { SupabaseService } from '../../supabase/supabase.service';

function makeQB(resolved: { data?: any; error?: any } = {}) {
  const value = { data: resolved.data ?? null, error: resolved.error ?? null };
  const qb: any = {
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue(value),
  };
  return qb;
}

const metadata: ArgumentMetadata = { type: 'query', metatype: String, data: 'category_id' };

describe('ValidCategoryPipe', () => {
  let pipe: ValidCategoryPipe;
  let adminClient: any;

  beforeEach(async () => {
    adminClient = { from: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ValidCategoryPipe,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    pipe = module.get<ValidCategoryPipe>(ValidCategoryPipe);
  });

  it('retorna UUID quando categoria existe e está ativa', async () => {
    adminClient.from.mockReturnValue(makeQB({ data: { id: 'cat-uuid-1' } }));

    const result = await pipe.transform('cat-uuid-1', metadata);

    expect(result).toBe('cat-uuid-1');
  });

  it('busca na tabela categories', async () => {
    adminClient.from.mockReturnValue(makeQB({ data: { id: 'cat-uuid-1' } }));

    await pipe.transform('cat-uuid-1', metadata);

    expect(adminClient.from).toHaveBeenCalledWith('categories');
  });

  it('filtra por is_active = true', async () => {
    const qb = makeQB({ data: { id: 'cat-uuid-1' } });
    adminClient.from.mockReturnValue(qb);

    await pipe.transform('cat-uuid-1', metadata);

    expect(qb.eq).toHaveBeenCalledWith('is_active', true);
  });

  it('filtra pelo id informado', async () => {
    const qb = makeQB({ data: { id: 'cat-uuid-1' } });
    adminClient.from.mockReturnValue(qb);

    await pipe.transform('cat-uuid-1', metadata);

    expect(qb.eq).toHaveBeenCalledWith('id', 'cat-uuid-1');
  });

  it('passa por valor null sem consultar o banco', async () => {
    const result = await pipe.transform(null, metadata);

    expect(result).toBeNull();
    expect(adminClient.from).not.toHaveBeenCalled();
  });

  it('passa por valor undefined sem consultar o banco', async () => {
    const result = await pipe.transform(undefined, metadata);

    expect(result).toBeUndefined();
    expect(adminClient.from).not.toHaveBeenCalled();
  });

  it('passa por string vazia sem consultar o banco', async () => {
    const result = await pipe.transform('', metadata);

    expect(result).toBe('');
    expect(adminClient.from).not.toHaveBeenCalled();
  });

  it('passa por número sem consultar o banco', async () => {
    const result = await pipe.transform(123, metadata);

    expect(result).toBe(123);
    expect(adminClient.from).not.toHaveBeenCalled();
  });

  it('lança BadRequestException quando categoria não é encontrada (erro no banco)', async () => {
    adminClient.from.mockReturnValue(
      makeQB({ data: null, error: { message: 'No rows found' } }),
    );

    await expect(pipe.transform('uuid-inexistente', metadata)).rejects.toThrow(BadRequestException);
  });

  it('lança BadRequestException quando data é null (categoria inativa)', async () => {
    adminClient.from.mockReturnValue(makeQB({ data: null }));

    await expect(pipe.transform('cat-inativa', metadata)).rejects.toThrow(BadRequestException);
  });

  it('mensagem de erro inclui o UUID inválido', async () => {
    adminClient.from.mockReturnValue(makeQB({ data: null }));

    try {
      await pipe.transform('uuid-invalido', metadata);
      fail('deveria ter lançado BadRequestException');
    } catch (e) {
      expect((e as BadRequestException).message).toContain('uuid-invalido');
    }
  });
});
