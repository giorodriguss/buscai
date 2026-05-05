import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsNotEmpty, Length } from 'class-validator';

export class UpdateUserDto {
  @ApiProperty({ example: 'João Silva', required: false })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  full_name?: string;

  @ApiProperty({ example: '11999999999', required: false })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ example: 'Encanador experiente da região', required: false })
  @IsString()
  @IsOptional()
  bio?: string;

  @ApiProperty({ example: 'Centro', required: false })
  @IsString()
  @IsOptional()
  neighborhood?: string;

  @ApiProperty({ example: 'São Paulo', required: false })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiProperty({ example: 'SP', required: false, maxLength: 2 })
  @IsString()
  @Length(2, 2)
  @IsOptional()
  state?: string;
}
