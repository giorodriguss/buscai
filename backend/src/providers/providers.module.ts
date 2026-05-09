import { Module } from '@nestjs/common';
import { ProvidersController } from './providers.controller';
import { ProvidersService } from './providers.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { ValidCategoryPipe } from '../pipes/valid-category.pipe';

@Module({
  imports: [SupabaseModule],
  controllers: [ProvidersController],
  providers: [ProvidersService, ValidCategoryPipe],
})
export class ProvidersModule {}