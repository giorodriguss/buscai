import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ProvidersService } from './providers.service';
import { CreateProviderDto } from './dto/create-provider.dto';
import { UpdateProviderDto } from './dto/update-provider.dto';
import { SearchProvidersDto } from './dto/search-providers.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BearerToken } from '../common/decorators/bearer-token.decorator';

@ApiTags('Providers')
@Controller('providers')
export class ProvidersController {
  constructor(private providersService: ProvidersService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Criar perfil de prestador' })
  create(@Request() req: any, @Body() dto: CreateProviderDto) {
    return this.providersService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Buscar prestadores por bairro/categoria' })
  findAll(@Query() query: SearchProvidersDto) {
    return this.providersService.findAll(query);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Meu perfil de prestador' })
  findMe(@Request() req: any) {
    return this.providersService.findMe(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalhes de um prestador' })
  findOne(@Param('id') id: string) {
    return this.providersService.findOne(id);
  }

  @Patch()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Atualizar perfil do prestador autenticado' })
  update(
    @Request() req: any,
    @BearerToken() token: string,
    @Body() dto: UpdateProviderDto,
  ) {
    return this.providersService.update(req.user.id, dto, token);
  }

  @Delete()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Desativar perfil do prestador' })
  deactivate(@BearerToken() token: string) {
    return this.providersService.deactivate(token);
  }
}
