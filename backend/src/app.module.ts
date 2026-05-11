import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CacheModule } from '@nestjs/cache-manager';
import { AppController } from './app.controller';
import { SupabaseModule } from './supabase/supabase.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { CategoriesModule } from './categories/categories.module';
import { PostsModule } from './posts/posts.module';
import { TagsModule } from './tags/tags.module';
import { ReviewsModule } from './reviews/reviews.module';
import { FavoritesModule } from './favorites/favorites.module';
import { AdsModule } from './ads/ads.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { UploadModule } from './upload/upload.module';
import { ProvidersModule } from './providers/providers.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    CacheModule.register({ isGlobal: true, ttl: 5 * 60 * 1000 }),

    SupabaseModule,
    AuthModule,
    UsersModule,
    CategoriesModule,
    PostsModule,
    TagsModule,
    ReviewsModule,
    FavoritesModule,
    AdsModule,
    SubscriptionsModule,
    UploadModule,
    ProvidersModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
