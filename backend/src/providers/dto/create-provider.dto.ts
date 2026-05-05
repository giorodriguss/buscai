import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export class CreateProviderDto {
  @ApiProperty({ example: 'Encanador com 10 anos de experiência' })
  @IsString()
  @IsNotEmpty()
  description!: string;

  @ApiProperty({ example: 'uuid-da-categoria' })
  @IsUUID()
  category_id!: string;

  @ApiProperty({ example: '11999999999' })
  @IsString()
  @IsNotEmpty()
  whatsapp!: string;

  @ApiProperty({ example: 'Centro' })
  @IsString()
  @IsNotEmpty()
  neighborhood!: string;

  @ApiProperty({ example: -23.5505, required: false })
  @IsNumber()
  @IsOptional()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @ApiProperty({ example: -46.6333, required: false })
  @IsNumber()
  @IsOptional()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @ApiProperty({ example: 'São Paulo', required: false })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiProperty({ example: 'SP', required: false })
  @IsString()
  @IsOptional()
  state?: string;

  @ApiProperty({
    example: 'Seg–Sex 08h–18h, Sáb 08h–12h',
    required: false,
    description: 'Horários de atendimento',
  })
  @IsString()
  @IsOptional()
  schedule?: string;
}
