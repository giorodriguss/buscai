import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
} from 'class-validator';
import { IsWhatsApp } from '../../common/validators/is-whatsapp.validator';

export class CreatePostDto {
  @ApiProperty({ example: 'Encanador residencial' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  title!: string;

  @ApiProperty({ example: 'Serviços de encanamento em geral', required: false })
  @IsString()
  @IsOptional()
  @MaxLength(2000)
  description?: string;

  @ApiProperty({ example: 'uuid-da-categoria' })
  @IsUUID()
  category_id!: string;

  @ApiProperty({ example: 50, required: false, minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  price_from?: number;

  @ApiProperty({ example: 200, required: false, minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  price_to?: number;

  @ApiProperty({ example: '11999999999', description: 'Número brasileiro com DDD, somente dígitos' })
  @IsString()
  @IsNotEmpty()
  @IsWhatsApp()
  whatsapp!: string;

  @ApiProperty({ example: 'Centro', required: false })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  neighborhood?: string;

  @ApiProperty({ example: 'São Paulo', required: false })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  city?: string;

  @ApiProperty({ example: 'SP', required: false })
  @IsString()
  @IsOptional()
  state?: string;

  @ApiProperty({ example: ['uuid-tag-1', 'uuid-tag-2'], required: false, type: [String] })
  @IsArray()
  @IsUUID('4', { each: true })
  @IsOptional()
  tag_ids?: string[];
}
