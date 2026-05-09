import {
  ArgumentMetadata,
  BadRequestException,
  Injectable,
  PipeTransform,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';


@Injectable()
export class ValidCategoryPipe implements PipeTransform {
  constructor(private readonly supabase: SupabaseService) {}

  async transform(value: unknown, _metadata: ArgumentMetadata): Promise<unknown> {
    // Só valida strings não-vazias; a validação de formato (IsUUID) já ocorre
    // antes nos DTOs via class-validator.
    if (typeof value !== 'string' || !value) return value;

    const { data, error } = await this.supabase
      .getAdminClient()
      .from('categories')
      .select('id')
      .eq('id', value)
      .eq('is_active', true)
      .single();

    if (error || !data) {
      throw new BadRequestException(
        `category_id inválido: categoria "${value}" não encontrada ou inativa`,
      );
    }

    return value;
  }
}