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
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { ProvidersService } from './providers.service';
import { CreateProviderDto } from './dto/create-provider.dto';
import { UpdateProviderDto } from './dto/update-provider.dto';
import { SearchProvidersDto } from './dto/search-providers.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BearerToken } from '../common/decorators/bearer-token.decorator';
import { ValidCategoryPipe } from '../common/pipes/valid-category.pipe';

@ApiTags('Providers')
@Controller('providers')
export class ProvidersController {
  constructor(
    private providersService: ProvidersService,
    private categoryPipe: ValidCategoryPipe,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Criar perfil de prestador' })
  @ApiResponse({ status: 201, description: 'Perfil de prestador criado' })
  @ApiResponse({ status: 400, description: 'Dados inválidos ou categoria inexistente' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  async create(@Request() req: any, @Body() dto: CreateProviderDto) {
    await this.categoryPipe.transform(dto.category_id, { type: 'body' });
    return this.providersService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Buscar prestadores por bairro/categoria ou geolocalização' })
  @ApiResponse({ status: 200, description: 'Lista de prestadores retornada' })
  findAll(@Query() query: SearchProvidersDto) {
    return this.providersService.findAll(query);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Meu perfil de prestador' })
  @ApiResponse({ status: 200, description: 'Perfil do prestador autenticado' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  findMe(@Request() req: any) {
    return this.providersService.findMe(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalhes de um prestador' })
  @ApiResponse({ status: 200, description: 'Dados do prestador' })
  @ApiResponse({ status: 404, description: 'Prestador não encontrado' })
  findOne(@Param('id') id: string) {
    return this.providersService.findOne(id);
  }

  @Patch()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Atualizar perfil do prestador autenticado' })
  @ApiResponse({ status: 200, description: 'Perfil atualizado com sucesso' })
  @ApiResponse({ status: 400, description: 'Dados inválidos' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
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
  @ApiResponse({ status: 200, description: 'Perfil desativado com sucesso' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  deactivate(@BearerToken() token: string) {
    return this.providersService.deactivate(token);
  }
}
