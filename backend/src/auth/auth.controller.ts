import {
  Body,
  Controller,
  Get,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { VerifyPasswordDto } from './dto/verify-password.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { AuthenticatedRequest } from '../common/interfaces/authenticated-request.interface';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @Throttle({ default: { ttl: 3_600_000, limit: 30 } }) // 30 cadastros/hora por IP
  @ApiOperation({ summary: 'Cadastrar novo usuário' })
  @ApiResponse({
    status: 201,
    description: 'Usuário criado — aguarda confirmação de e-mail',
  })
  @ApiResponse({
    status: 400,
    description: 'Dados inválidos ou e-mail já cadastrado',
  })
  @ApiResponse({
    status: 429,
    description: 'Limite de cadastros por hora atingido',
  })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @Throttle({ default: { ttl: 900_000, limit: 10 } }) // 10 tentativas/15min por IP
  @ApiOperation({ summary: 'Fazer login' })
  @ApiResponse({
    status: 200,
    description: 'Login bem-sucedido — retorna access_token e dados do usuário',
  })
  @ApiResponse({ status: 401, description: 'Credenciais inválidas' })
  @ApiResponse({
    status: 429,
    description: 'Muitas tentativas de login — tente novamente em 15 min',
  })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('change-password')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Redefinir senha do usuário autenticado' })
  @ApiResponse({ status: 200, description: 'Senha atualizada com sucesso' })
  @ApiResponse({
    status: 401,
    description: 'Senha atual não confere ou token inválido',
  })
  changePassword(
    @Request() req: AuthenticatedRequest,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.authService.changePassword(req.user.id, dto);
  }

  @Post('verify-password')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Verificar senha atual do usuário autenticado' })
  @ApiResponse({ status: 200, description: 'Senha atual confere' })
  @ApiResponse({
    status: 401,
    description: 'Senha atual não confere ou token inválido',
  })
  verifyPassword(
    @Request() req: AuthenticatedRequest,
    @Body() dto: VerifyPasswordDto,
  ) {
    return this.authService.verifyPassword(req.user.id, dto);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Dados do usuário autenticado' })
  @ApiResponse({ status: 200, description: 'Perfil do usuário autenticado' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  me(@Request() req: AuthenticatedRequest) {
    return this.authService.me(req.user.id);
  }
}
