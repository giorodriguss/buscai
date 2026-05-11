import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { SupabaseService } from '../supabase/supabase.service';
import { FREE_PLAN_MAX_PHOTOS, MAX_AVATAR_SIZE_MB, MAX_PHOTO_SIZE_MB } from '../common/constants';

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
const MAX_AVATAR_SIZE = MAX_AVATAR_SIZE_MB * 1024 * 1024;
const MAX_PHOTO_SIZE  = MAX_PHOTO_SIZE_MB  * 1024 * 1024;

function validateImage(file: Express.Multer.File, maxSize: number): void {
  if (!file) throw new BadRequestException('Nenhum arquivo enviado');
  if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    throw new BadRequestException(
      'Tipo de arquivo não permitido. Use JPEG, PNG, WebP ou GIF',
    );
  }
  if (file.size > maxSize) {
    throw new BadRequestException(
      `Arquivo muito grande. Tamanho máximo: ${maxSize / 1024 / 1024} MB`,
    );
  }
}

function mimeToExt(mime: string): string {
  const map: Record<string, string> = {
    'image/jpeg': 'jpg',
    'image/png':  'png',
    'image/webp': 'webp',
    'image/gif':  'gif',
  };
  return map[mime] ?? 'jpg';
}

@Injectable()
export class UploadService {
  private readonly logger = new Logger(UploadService.name);

  constructor(private supabase: SupabaseService) {}

  async uploadAvatar(userId: string, file: Express.Multer.File, token: string) {
    validateImage(file, MAX_AVATAR_SIZE);

    const ext  = mimeToExt(file.mimetype);
    const path = `avatars/${userId}.${ext}`;

    const { error } = await this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .upload(path, file.buffer, { contentType: file.mimetype, upsert: true });

    if (error) {
      this.logger.error(`Avatar upload failed for user ${userId}: ${error.message}`);
      throw new BadRequestException('Erro ao fazer upload do avatar');
    }

    const { data } = this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .getPublicUrl(path);

    // Usa user client para que o RLS valide auth.uid() = id
    await this.supabase
      .getUserClient(token)
      .from('users')
      .update({ avatar_url: data.publicUrl })
      .eq('id', userId);

    return { url: data.publicUrl };
  }

  async uploadPostPhoto(
    userId: string,
    postId: string,
    file: Express.Multer.File,
    caption?: string,
  ) {
    validateImage(file, MAX_PHOTO_SIZE);

    const { data: sub } = await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .select('max_photos')
      .eq('user_id', userId)
      .single();

    const maxPhotos = sub?.max_photos ?? FREE_PLAN_MAX_PHOTOS;

    // Faz o upload para o storage antes de chamar a RPC
    const ext  = mimeToExt(file.mimetype);
    const path = `posts/${postId}/${randomUUID()}.${ext}`;

    const { error: storageError } = await this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .upload(path, file.buffer, { contentType: file.mimetype });

    if (storageError) {
      this.logger.error(`Post photo upload failed: ${storageError.message}`);
      throw new BadRequestException('Erro ao fazer upload da foto');
    }

    const { data: urlData } = this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .getPublicUrl(path);

    // RPC atômica: verifica ownership, limite e insere em uma transação
    const { data: rows, error: rpcError } = await this.supabase
      .getAdminClient()
      .rpc('add_post_photo_atomic', {
        p_post_id:     postId,
        p_user_id:     userId,
        p_max_photos:  maxPhotos,
        p_storage_url: urlData.publicUrl,
        p_caption:     caption ?? null,
      });

    if (rpcError) {
      // Reverte o arquivo do storage se a RPC falhou
      await this.supabase.getAdminClient().storage.from('buscai').remove([path]);

      if (rpcError.message.includes('LIMIT_REACHED')) {
        throw new BadRequestException(`Seu plano permite no máximo ${maxPhotos} foto(s) por post`);
      }
      if (rpcError.message.includes('FORBIDDEN')) {
        throw new ForbiddenException('Sem permissão para adicionar foto neste post');
      }
      this.logger.error(`add_post_photo_atomic failed: ${rpcError.message}`);
      throw new BadRequestException('Erro ao salvar foto');
    }

    return Array.isArray(rows) ? rows[0] : rows;
  }

  async deletePostPhoto(photoId: string, token: string) {
    // user client aplica RLS: "Dono da postagem gerencia fotos"
    const userClient = this.supabase.getUserClient(token);

    const { error } = await userClient
      .from('post_photos')
      .delete()
      .eq('id', photoId);

    if (error) {
      this.logger.error(`Delete post photo failed: ${error.message}`);
      throw new BadRequestException('Erro ao remover foto');
    }
    return { message: 'Foto removida' };
  }

  async uploadPortfolioImage(userId: string, file: Express.Multer.File) {
    validateImage(file, MAX_PHOTO_SIZE);

    const ext  = mimeToExt(file.mimetype);
    const path = `portfolio/${userId}/${randomUUID()}.${ext}`;

    const { error: storageError } = await this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .upload(path, file.buffer, { contentType: file.mimetype });

    if (storageError) {
      this.logger.error(`Portfolio upload failed for user ${userId}: ${storageError.message}`);
      throw new BadRequestException('Erro ao fazer upload da imagem');
    }

    const { data: urlData } = this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .getPublicUrl(path);

    const { data, error } = await this.supabase
      .getAdminClient()
      .from('portfolio_images')
      .insert({ provider_id: userId, url: urlData.publicUrl })
      .select()
      .single();

    if (error) {
      this.logger.error(`Portfolio DB insert failed: ${error.message}`);
      throw new BadRequestException('Erro ao salvar imagem');
    }
    return data;
  }

  async deletePortfolioImage(imageId: string, userId: string) {
    const { data: image } = await this.supabase
      .getAdminClient()
      .from('portfolio_images')
      .select('provider_id')
      .eq('id', imageId)
      .single();

    if (!image) throw new NotFoundException('Imagem não encontrada');
    if (image.provider_id !== userId) throw new ForbiddenException('Sem permissão');

    const { error } = await this.supabase
      .getAdminClient()
      .from('portfolio_images')
      .delete()
      .eq('id', imageId);

    if (error) {
      this.logger.error(`Delete portfolio image failed: ${error.message}`);
      throw new BadRequestException('Erro ao remover imagem');
    }
    return { message: 'Imagem removida' };
  }
}
