import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength, MaxLength } from 'class-validator';

export class ChangePasswordDto {
  @ApiProperty({ example: 'senhaAtual123' })
  @IsString()
  currentPassword: string;

  @ApiProperty({ example: 'novaSenha123', minLength: 6, maxLength: 12 })
  @IsString()
  @MinLength(6)
  @MaxLength(12)
  newPassword: string;
}
