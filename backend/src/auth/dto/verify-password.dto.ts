import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class VerifyPasswordDto {
  @ApiProperty({ example: 'senhaAtual123' })
  @IsString()
  currentPassword: string;
}
