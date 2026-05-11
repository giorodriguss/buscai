import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  private readonly logger = new Logger(ReviewsService.name);

  constructor(private supabase: SupabaseService) {}

  async create(reviewerId: string, dto: CreateReviewDto, token: string) {
    const { data: post } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select('user_id')
      .eq('id', dto.post_id)
      .single();

    if (post?.user_id === reviewerId) {
      throw new ForbiddenException('Você não pode avaliar seu próprio post');
    }

    // user client aplica RLS: reviewer_id = auth.uid()
    const { data, error } = await this.supabase
      .getUserClient(token)
      .from('reviews')
      .insert({ reviewer_id: reviewerId, ...dto })
      .select()
      .single();

    if (error) {
      this.logger.error(`Create review failed for post ${dto.post_id}: ${error.message}`);
      throw new BadRequestException('Não foi possível criar a avaliação');
    }

    await this.updatePostRating(dto.post_id);
    return data;
  }

  async findByPost(postId: string, page = 1, limit = 20) {
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data, error, count } = await this.supabase
      .getAdminClient()
      .from('reviews')
      .select('*, users(id, full_name, avatar_url)', { count: 'exact' })
      .eq('post_id', postId)
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) {
      this.logger.error(`Find reviews for post ${postId} failed: ${error.message}`);
      throw new BadRequestException('Não foi possível buscar as avaliações');
    }
    return { data, total: count, page, limit };
  }

  async delete(reviewId: string, token: string) {
    // Busca post_id antes de deletar para atualizar o rating depois
    const { data, error: fetchError } = await this.supabase
      .getAdminClient()
      .from('reviews')
      .select('post_id')
      .eq('id', reviewId)
      .single();

    if (fetchError || !data) throw new NotFoundException('Avaliação não encontrada');

    // user client aplica RLS: só deleta se reviewer_id = auth.uid()
    const { error } = await this.supabase
      .getUserClient(token)
      .from('reviews')
      .delete()
      .eq('id', reviewId);

    if (error) {
      this.logger.error(`Delete review ${reviewId} failed: ${error.message}`);
      throw new BadRequestException('Não foi possível remover a avaliação');
    }

    await this.updatePostRating(data.post_id);
    return { message: 'Avaliação removida' };
  }

  private async updatePostRating(postId: string) {
    const { data: reviews } = await this.supabase
      .getAdminClient()
      .from('reviews')
      .select('rating')
      .eq('post_id', postId);

    const ratings = (reviews ?? []).map((r: any) => r.rating as number);
    const rating_count = ratings.length;
    const rating_avg =
      rating_count > 0
        ? Math.round((ratings.reduce((s, r) => s + r, 0) / rating_count) * 10) / 10
        : 0;

    await this.supabase
      .getAdminClient()
      .from('posts')
      .update({ rating_avg, rating_count })
      .eq('id', postId);
  }
}
