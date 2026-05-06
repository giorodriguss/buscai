import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class SearchProvidersDto {
  @ApiProperty({ example: 'Centro', required: false })
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

  @ApiProperty({ example: 'uuid-da-categoria', required: false })
  @IsUUID()
  @IsOptional()
  category_id?: string;

  @ApiProperty({ required: false, description: 'Latitude para busca por raio' })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  lat?: number;

  @ApiProperty({ required: false, description: 'Longitude para busca por raio' })
  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  lng?: number;

  @ApiProperty({ required: false, default: 10, description: 'Raio de busca em km (máx 100)' })
  @Type(() => Number)
  @IsNumber()
  @Min(0.1)
  @Max(100)
  @IsOptional()
  radius_km?: number;

  @ApiProperty({ example: 1, required: false, default: 1 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  page?: number = 1;

  @ApiProperty({ example: 10, required: false, default: 10, maximum: 100 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 10;
}
