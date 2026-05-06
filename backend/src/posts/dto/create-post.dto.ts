import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Min,
} from 'class-validator';

export class CreatePostDto {
  @ApiProperty({ example: 'Encanador residencial' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({ example: 'Serviços de encanamento em geral', required: false })
  @IsString()
  @IsOptional()
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

  @ApiProperty({ example: '11999999999' })
  @IsString()
  @IsNotEmpty()
  whatsapp!: string;

  @ApiProperty({ example: 'Centro', required: false })
  @IsString()
  @IsOptional()
  neighborhood?: string;

  @ApiProperty({ example: 'São Paulo', required: false })
  @IsString()
  @IsOptional()
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
