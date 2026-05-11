import { Body, Controller, Get, Param, Patch, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AuthenticatedRequest } from '../common/interfaces/authenticated-request.interface';
import { BearerToken } from '../common/decorators/bearer-token.decorator';

@ApiTags('Users')
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Perfil do usuário autenticado' })
  getMe(@Request() req: AuthenticatedRequest) {
    return this.usersService.findOne(req.user.id);
  }

  @Patch('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Atualizar nome e bairro do usuário' })
  updateMe(
    @Request() req: AuthenticatedRequest,
    @BearerToken() token: string,
    @Body() dto: UpdateUserDto,
  ) {
    return this.usersService.update(req.user.id, dto, token);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Perfil público de qualquer usuário' })
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }
}
