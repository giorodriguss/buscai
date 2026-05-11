import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { UploadService } from './upload.service';
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
    single: jest.fn().mockResolvedValue(value),
    then: (res: Function, rej: Function) => Promise.resolve(value).then(res as any, rej as any),
  };
  return qb;
}

function makeStorageBucket({ uploadError = null, publicUrl = 'https://cdn.example.com/file.jpg' } = {}) {
  return {
    upload: jest.fn().mockResolvedValue({ error: uploadError }),
    getPublicUrl: jest.fn().mockReturnValue({ data: { publicUrl } }),
  };
}

const mockFile: Express.Multer.File = {
  fieldname: 'file',
  originalname: 'foto.jpg',
  encoding: '7bit',
  mimetype: 'image/jpeg',
  buffer: Buffer.from('fake-image-data'),
  size: 100,
  stream: null as any,
  destination: '',
  filename: '',
  path: '',
};

describe('UploadService', () => {
  let service: UploadService;
  let adminClient: any;
  let storageBucket: ReturnType<typeof makeStorageBucket>;

  beforeEach(async () => {
    storageBucket = makeStorageBucket();
    adminClient = {
      from: jest.fn(),
      storage: { from: jest.fn().mockReturnValue(storageBucket) },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UploadService,
        {
          provide: SupabaseService,
          useValue: { getAdminClient: jest.fn().mockReturnValue(adminClient) },
        },
      ],
    }).compile();

    service = module.get<UploadService>(UploadService);
  });

  describe('uploadAvatar', () => {
    it('retorna URL pública do avatar após upload', async () => {
      adminClient.from.mockReturnValue(makeQB());

      const result = await service.uploadAvatar('user-1', mockFile, 'mock-token');

      expect(result).toEqual({ url: 'https://cdn.example.com/file.jpg' });
    });

    it('faz upload para o bucket buscai no caminho avatars/{userId}.ext', async () => {
      adminClient.from.mockReturnValue(makeQB());

      await service.uploadAvatar('user-1', mockFile, 'mock-token');

      expect(adminClient.storage.from).toHaveBeenCalledWith('buscai');
      expect(storageBucket.upload).toHaveBeenCalledWith(
        'avatars/user-1.jpg',
        mockFile.buffer,
        expect.objectContaining({ contentType: 'image/jpeg', upsert: true }),
      );
    });

    it('atualiza avatar_url do usuário no banco após upload', async () => {
      const qb = makeQB();
      adminClient.from.mockReturnValue(qb);

      await service.uploadAvatar('user-1', mockFile, 'mock-token');

      expect(adminClient.from).toHaveBeenCalledWith('users');
      expect(qb.update).toHaveBeenCalledWith({ avatar_url: 'https://cdn.example.com/file.jpg' });
      expect(qb.eq).toHaveBeenCalledWith('id', 'user-1');
    });

    it('lança BadRequestException quando upload no storage falha', async () => {
      storageBucket.upload.mockResolvedValue({ error: { message: 'Bucket cheio' } });

      await expect(service.uploadAvatar('user-1', mockFile, 'mock-token')).rejects.toThrow(BadRequestException);
    });
  });

  describe('uploadPostPhoto', () => {
    it('faz upload e retorna dados da foto inserida', async () => {
      const mockPhoto = { id: 'photo-1', storage_url: 'https://cdn.example.com/photo.jpg' };
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { max_photos: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 2 }))
        .mockReturnValueOnce(makeQB({ data: mockPhoto }));

      const result = await service.uploadPostPhoto('user-1', 'post-1', mockFile);

      expect(result).toEqual(mockPhoto);
    });

    it('lança NotFoundException quando post não existe', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(
        service.uploadPostPhoto('user-1', 'post-inexistente', mockFile),
      ).rejects.toThrow(NotFoundException);
    });

    it('lança ForbiddenException quando usuário não é dono do post', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { user_id: 'outro-user' } }));

      await expect(
        service.uploadPostPhoto('user-1', 'post-1', mockFile),
      ).rejects.toThrow(ForbiddenException);
    });

    it('usa max_photos = 3 quando não há assinatura e já atingiu o limite', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: null }))
        .mockReturnValueOnce(makeQB({ count: 3 }));

      await expect(
        service.uploadPostPhoto('user-1', 'post-1', mockFile),
      ).rejects.toThrow(BadRequestException);
    });

    it('lança BadRequestException quando limite de fotos do plano é atingido', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { max_photos: 3 } }))
        .mockReturnValueOnce(makeQB({ count: 3 }));

      await expect(
        service.uploadPostPhoto('user-1', 'post-1', mockFile),
      ).rejects.toThrow(new BadRequestException('Seu plano permite no máximo 3 foto(s) por post'));
    });

    it('lança BadRequestException quando upload no storage falha', async () => {
      storageBucket.upload.mockResolvedValue({ error: { message: 'Erro de storage' } });
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { max_photos: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 0 }));

      await expect(
        service.uploadPostPhoto('user-1', 'post-1', mockFile),
      ).rejects.toThrow(BadRequestException);
    });

    it('lança BadRequestException quando insert no banco falha', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { max_photos: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 0 }))
        .mockReturnValueOnce(makeQB({ error: { message: 'Constraint violation' } }));

      await expect(
        service.uploadPostPhoto('user-1', 'post-1', mockFile),
      ).rejects.toThrow(BadRequestException);
    });

    it('insere sort_order igual ao photoCount atual', async () => {
      const insertQB = makeQB({ data: { id: 'photo-1' } });
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { user_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ data: { max_photos: 5 } }))
        .mockReturnValueOnce(makeQB({ count: 2 }))
        .mockReturnValueOnce(insertQB);

      await service.uploadPostPhoto('user-1', 'post-1', mockFile);

      expect(insertQB.insert).toHaveBeenCalledWith(
        expect.objectContaining({ sort_order: 2, post_id: 'post-1' }),
      );
    });
  });

  describe('deletePostPhoto', () => {
    it('remove foto quando usuário é dono do post', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { id: 'photo-1', posts: { user_id: 'user-1' } } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.deletePostPhoto('photo-1', 'user-1');

      expect(result).toEqual({ message: 'Foto removida' });
    });

    it('lança NotFoundException quando foto não existe', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.deletePostPhoto('foto-inexistente', 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('lança ForbiddenException quando usuário não é dono do post', async () => {
      adminClient.from.mockReturnValue(
        makeQB({ data: { id: 'photo-1', posts: { user_id: 'outro-user' } } }),
      );

      await expect(service.deletePostPhoto('photo-1', 'user-1')).rejects.toThrow(ForbiddenException);
    });

    it('lança BadRequestException quando delete falha no banco', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { id: 'photo-1', posts: { user_id: 'user-1' } } }))
        .mockReturnValueOnce(makeQB({ error: { message: 'FK constraint' } }));

      await expect(service.deletePostPhoto('photo-1', 'user-1')).rejects.toThrow(BadRequestException);
    });
  });

  describe('uploadPortfolioImage', () => {
    it('retorna dados da imagem inserida no portfolio', async () => {
      const mockImage = { id: 'img-1', provider_id: 'user-1', url: 'https://cdn.example.com/port.jpg' };
      adminClient.from.mockReturnValue(makeQB({ data: mockImage }));

      const result = await service.uploadPortfolioImage('user-1', mockFile);

      expect(result).toEqual(mockImage);
    });

    it('faz upload para o caminho portfolio/{userId}/...', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { id: 'img-1' } }));

      await service.uploadPortfolioImage('user-1', mockFile);

      expect(storageBucket.upload).toHaveBeenCalledWith(
        expect.stringMatching(/^portfolio\/user-1\//),
        mockFile.buffer,
        expect.objectContaining({ contentType: 'image/jpeg' }),
      );
    });

    it('insere provider_id e url corretos no banco', async () => {
      const qb = makeQB({ data: { id: 'img-1' } });
      adminClient.from.mockReturnValue(qb);

      await service.uploadPortfolioImage('user-1', mockFile);

      expect(qb.insert).toHaveBeenCalledWith({
        provider_id: 'user-1',
        url: 'https://cdn.example.com/file.jpg',
      });
    });

    it('lança BadRequestException quando upload no storage falha', async () => {
      storageBucket.upload.mockResolvedValue({ error: { message: 'Bucket cheio' } });

      await expect(service.uploadPortfolioImage('user-1', mockFile)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('lança BadRequestException quando insert no banco falha', async () => {
      adminClient.from.mockReturnValue(makeQB({ error: { message: 'Constraint error' } }));

      await expect(service.uploadPortfolioImage('user-1', mockFile)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('deletePortfolioImage', () => {
    it('remove imagem do portfolio quando usuário é o dono', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { provider_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB());

      const result = await service.deletePortfolioImage('img-1', 'user-1');

      expect(result).toEqual({ message: 'Imagem removida' });
    });

    it('lança NotFoundException quando imagem não existe', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: null }));

      await expect(service.deletePortfolioImage('img-inexistente', 'user-1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('lança ForbiddenException quando usuário não é o dono da imagem', async () => {
      adminClient.from.mockReturnValue(makeQB({ data: { provider_id: 'outro-user' } }));

      await expect(service.deletePortfolioImage('img-1', 'user-1')).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('lança BadRequestException quando delete falha no banco', async () => {
      adminClient.from
        .mockReturnValueOnce(makeQB({ data: { provider_id: 'user-1' } }))
        .mockReturnValueOnce(makeQB({ error: { message: 'Erro ao deletar' } }));

      await expect(service.deletePortfolioImage('img-1', 'user-1')).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
