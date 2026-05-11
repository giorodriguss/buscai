import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CacheModule } from '@nestjs/cache-manager';
import { ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard } from '@nestjs/throttler';
import { envValidationSchema } from './config/env.validation';
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
<<<<<<< HEAD
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: envValidationSchema,
      validationOptions: { abortEarly: false },
    }),

    CacheModule.register({ isGlobal: true, ttl: 5 * 60 * 1000 }),

    // Global rate limit: 120 req / min por IP (proteção geral)
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 120 }]),

=======
    ConfigModule.forRoot({ isGlobal: true }),

    CacheModule.register({ isGlobal: true, ttl: 5 * 60 * 1000 }),

>>>>>>> origin/develop
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
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
