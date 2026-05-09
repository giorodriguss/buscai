import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';
import { IsWhatsApp } from '../../common/validators/is-whatsapp.validator';

export class UpdatePostDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  title?: string;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ required: false })
  @IsUUID()
  @IsOptional()
  category_id?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  price_from?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  price_to?: number;

  @ApiProperty({ example: '11999999999', required: false, description: 'Número brasileiro com DDD, somente dígitos' })
  @IsString()
  @IsWhatsApp()
  @IsOptional()
  whatsapp?: string;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  neighborhood?: string;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  state?: string;

  @ApiProperty({ required: false, type: [String] })
  @IsArray()
  @IsUUID('4', { each: true })
  @IsOptional()
  tag_ids?: string[];
}