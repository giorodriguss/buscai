import { Module } from '@nestjs/common';
import { PostsController } from './posts.controller';
import { PostsService } from './posts.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { ValidCategoryPipe } from '../common/pipes/valid-category.pipe';

@Module({
  imports: [SupabaseModule],
  controllers: [PostsController],
  providers: [PostsService, ValidCategoryPipe],
})
export class PostsModule {}
