import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  Length,
  MaxLength,
  MinLength,
} from 'class-validator';
import { IsWhatsApp } from '../../common/validators/is-whatsapp.validator';

export class RegisterDto {
  @ApiProperty({ example: 'João Silva' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  full_name: string;

  @ApiProperty({ example: 'joao@email.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'senha123', minLength: 6 })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ example: 'morador', enum: ['morador', 'prestador'] })
  @IsIn(['morador', 'prestador'])
  role: 'morador' | 'prestador';

  @ApiProperty({ example: '11999999999', required: false, description: 'Número brasileiro com DDD, somente dígitos' })
  @IsString()
  @IsWhatsApp()
  @IsOptional()
  phone?: string;

  @ApiProperty({ example: '123.456.789-00', required: false })
  @IsString()
  @IsOptional()
  @MaxLength(14)
  cpf?: string;

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
