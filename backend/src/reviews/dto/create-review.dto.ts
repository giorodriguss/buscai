import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';

export class CreateReviewDto {
  @ApiProperty({ example: 'uuid-do-post' })
  @IsUUID()
  post_id: string;

  @ApiProperty({ example: 5, minimum: 1, maximum: 5 })
  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiProperty({ example: 'Ótimo serviço, muito pontual!', required: false })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  comment?: string;
}
