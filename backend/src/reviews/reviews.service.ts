import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(private supabase: SupabaseService) {}

  async create(reviewerId: string, dto: CreateReviewDto) {
    // Block self-review: check if the post belongs to the reviewer
    const { data: post } = await this.supabase
      .getAdminClient()
      .from('posts')
      .select('user_id')
      .eq('id', dto.post_id)
      .single();

    if (post?.user_id === reviewerId) {
      throw new ForbiddenException('Você não pode avaliar seu próprio post');
    }

    const { data, error } = await this.supabase
      .getAdminClient()
      .from('reviews')
      .insert({ reviewer_id: reviewerId, ...dto })
      .select()
      .single();

    if (error) throw new BadRequestException(error.message);
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

    if (error) throw new BadRequestException(error.message);
    return { data, total: count, page, limit };
  }

  async delete(reviewId: string, userId: string) {
    const { data, error } = await this.supabase
      .getAdminClient()
      .from('reviews')
      .select('reviewer_id')
      .eq('id', reviewId)
      .single();

    if (error || !data) throw new NotFoundException('Avaliação não encontrada');
    if (data.reviewer_id !== userId) throw new ForbiddenException();

    await this.supabase
      .getAdminClient()
      .from('reviews')
      .delete()
      .eq('id', reviewId);

    return { message: 'Avaliação removida' };
  }
}
