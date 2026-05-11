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
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BearerToken } from '../common/decorators/bearer-token.decorator';
import { ValidCategoryPipe } from '../common/pipes/valid-category.pipe';

@ApiTags('Posts')
@Controller('posts')
export class PostsController {
  constructor(
    private postsService: PostsService,
    private categoryPipe: ValidCategoryPipe,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Criar novo post de serviço' })
  @ApiResponse({ status: 201, description: 'Post criado com sucesso' })
  @ApiResponse({ status: 400, description: 'Dados inválidos ou categoria inexistente' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  async create(@Request() req: any, @Body() dto: CreatePostDto) {
    await this.categoryPipe.transform(dto.category_id, { type: 'body' });
    return this.postsService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar posts com filtros' })
  @ApiResponse({ status: 200, description: 'Lista de posts retornada' })
  findAll(@Query() dto: SearchPostsDto) {
    return this.postsService.findAll(dto);
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Listar meus posts' })
  @ApiResponse({ status: 200, description: 'Lista de posts do usuário autenticado' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  findMine(@BearerToken() token: string) {
    return this.postsService.findByUser(token);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalhe de um post (incrementa views)' })
  @ApiResponse({ status: 200, description: 'Dados do post' })
  @ApiResponse({ status: 404, description: 'Post não encontrado' })
  findOne(@Param('id') id: string) {
    return this.postsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Atualizar post (somente dono)' })
  @ApiResponse({ status: 200, description: 'Post atualizado com sucesso' })
  @ApiResponse({ status: 400, description: 'Dados inválidos' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  @ApiResponse({ status: 403, description: 'Sem permissão para editar este post' })
  @ApiResponse({ status: 404, description: 'Post não encontrado' })
  update(
    @Param('id') id: string,
    @BearerToken() token: string,
    @Body() dto: UpdatePostDto,
  ) {
    return this.postsService.update(id, dto, token);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remover post (somente dono)' })
  @ApiResponse({ status: 200, description: 'Post removido com sucesso' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  @ApiResponse({ status: 403, description: 'Sem permissão para remover este post' })
  @ApiResponse({ status: 404, description: 'Post não encontrado' })
  remove(@Param('id') id: string, @BearerToken() token: string) {
    return this.postsService.remove(id, token);
  }
}
