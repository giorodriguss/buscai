import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class UploadService {
  constructor(private supabase: SupabaseService) {}

  async uploadAvatar(userId: string, file: Express.Multer.File) {
    const ext = file.originalname.split('.').pop();
    const path = `avatars/${userId}.${ext}`;

    const { error } = await this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .upload(path, file.buffer, { contentType: file.mimetype, upsert: true });

    if (error) throw new BadRequestException(error.message);

    const { data } = this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .getPublicUrl(path);

    await this.supabase
      .getAdminClient()
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
    const { data: post } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select('user_id')
      .eq('id', postId)
      .single();

    if (!post) throw new NotFoundException('Post não encontrado');
    if (post.user_id !== userId) throw new ForbiddenException('Sem permissão');

    const { data: sub } = await this.supabase
      .getAdminClient()
      .from('subscriptions')
      .select('max_photos')
      .eq('user_id', userId)
      .single();

    const { count: photoCount } = await this.supabase
      .getAdminClient()
      .from('post_photos')
      .select('id', { count: 'exact', head: true })
      .eq('post_id', postId);

    const maxPhotos = sub?.max_photos ?? 3;
    if ((photoCount ?? 0) >= maxPhotos) {
      throw new BadRequestException(
        `Seu plano permite no máximo ${maxPhotos} foto(s) por post`,
      );
    }

    const ext = file.originalname.split('.').pop();
    const path = `posts/${postId}/${Date.now()}.${ext}`;

    const { error: storageError } = await this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .upload(path, file.buffer, { contentType: file.mimetype });

    if (storageError) throw new BadRequestException(storageError.message);

    const { data: urlData } = this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .getPublicUrl(path);

    const { data: photo, error: dbError } = await this.supabase
      .getAdminClient()
      .from('post_photos')
      .insert({
        post_id: postId,
        storage_url: urlData.publicUrl,
        caption: caption ?? null,
        sort_order: photoCount ?? 0,
      })
      .select()
      .single();

    if (dbError) throw new BadRequestException(dbError.message);
    return photo;
  }

  async deletePostPhoto(photoId: string, userId: string) {
    const { data: photo } = await this.supabase
      .getAdminClient()
      .from('post_photos')
      .select('id, posts(user_id)')
      .eq('id', photoId)
      .single();

    if (!photo) throw new NotFoundException('Foto não encontrada');

    const postOwner = (photo as any).posts?.user_id;
    if (postOwner !== userId) throw new ForbiddenException('Sem permissão');

    const { error } = await this.supabase
      .getAdminClient()
      .from('post_photos')
      .delete()
      .eq('id', photoId);

    if (error) throw new BadRequestException(error.message);
    return { message: 'Foto removida' };
  }

  async uploadPortfolioImage(userId: string, file: Express.Multer.File) {
    const ext = file.originalname.split('.').pop();
    const path = `portfolio/${userId}/${Date.now()}.${ext}`;

    const { error: storageError } = await this.supabase
      .getAdminClient()
      .storage.from('buscai')
      .upload(path, file.buffer, { contentType: file.mimetype });

    if (storageError) throw new BadRequestException(storageError.message);

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

    if (error) throw new BadRequestException(error.message);
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

    if (error) throw new BadRequestException(error.message);
    return { message: 'Imagem removida' };
  }
}
