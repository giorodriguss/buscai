import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CacheModule } from '@nestjs/cache-manager';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
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

    // ── Rate limiting ──────────────────────────────────────────────────────────
    // Limites por janela de tempo, aplicados globalmente via APP_GUARD abaixo.
    // Valores lidos do .env; os defaults abaixo são conservadores para produção.
    //
    //   THROTTLE_SHORT_TTL   (segundos) — janela curta,  default 1s
    //   THROTTLE_SHORT_LIMIT (requests) — default 5 req/s   por IP
    //   THROTTLE_LONG_TTL    (segundos) — janela longa, default 60s
    //   THROTTLE_LONG_LIMIT  (requests) — default 60 req/min por IP
    //
    // Para desabilitar o rate limit em um endpoint específico, use:
    //   @SkipThrottle() no controller/método
    ThrottlerModule.forRootAsync({
      useFactory: () => ({
        throttlers: [
          {
            name: 'short',
            ttl: Number(process.env.THROTTLE_SHORT_TTL ?? 1) * 1000,
            limit: Number(process.env.THROTTLE_SHORT_LIMIT ?? 5),
          },
          {
            name: 'long',
            ttl: Number(process.env.THROTTLE_LONG_TTL ?? 60) * 1000,
            limit: Number(process.env.THROTTLE_LONG_LIMIT ?? 60),
          },
        ],
      }),
    }),

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
  providers: [
    // Guard global de rate limiting — aplica automaticamente em todas as rotas
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}