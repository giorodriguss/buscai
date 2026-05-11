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
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { SearchPostsDto } from './dto/search-posts.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
<<<<<<< HEAD
import { BearerToken } from '../common/decorators/bearer-token.decorator';
=======
import { ValidCategoryPipe } from '../common/pipes/valid-category.pipe';
>>>>>>> origin/develop

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
  async create(@Request() req: any, @Body() dto: CreatePostDto) {
    await this.categoryPipe.transform(dto.category_id, { type: 'body' });
    return this.postsService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar posts com filtros' })
  findAll(@Query() dto: SearchPostsDto) {
    return this.postsService.findAll(dto);
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Listar meus posts' })
  findMine(@BearerToken() token: string) {
    return this.postsService.findByUser(token);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalhe de um post (incrementa views)' })
  findOne(@Param('id') id: string) {
    return this.postsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Atualizar post (somente dono)' })
<<<<<<< HEAD
  update(
    @Param('id') id: string,
    @BearerToken() token: string,
    @Body() dto: UpdatePostDto,
  ) {
    return this.postsService.update(id, dto, token);
=======
  async update(@Param('id') id: string, @Request() req: any, @Body() dto: UpdatePostDto) {
    if (dto.category_id) {
      await this.categoryPipe.transform(dto.category_id, { type: 'body' });
    }
    return this.postsService.update(id, req.user.id, dto);
>>>>>>> origin/develop
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remover post (somente dono)' })
  remove(@Param('id') id: string, @BearerToken() token: string) {
    return this.postsService.remove(id, token);
  }
}
