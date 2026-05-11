import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsNotEmpty, Length, MaxLength } from 'class-validator';

export class UpdateUserDto {
  @ApiProperty({ example: 'João Silva', required: false })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  @MaxLength(100)
  full_name?: string;

  @ApiProperty({ example: '11999999999', required: false })
  @IsString()
  @IsOptional()
  @MaxLength(20)
  phone?: string;

  @ApiProperty({ example: 'Encanador experiente da região', required: false })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  bio?: string;

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

  @ApiProperty({ example: 'SP', required: false, maxLength: 2 })
  @IsString()
  @Length(2, 2)
  @IsOptional()
  state?: string;
}
