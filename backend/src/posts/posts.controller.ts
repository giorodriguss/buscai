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

@ApiTags('Posts')
@Controller('posts')
export class PostsController {
  constructor(private postsService: PostsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Criar novo post de serviço' })
  create(@Request() req: any, @Body() dto: CreatePostDto) {
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
  findMine(@Request() req: any) {
    return this.postsService.findByUser(req.user.id);
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
  update(@Param('id') id: string, @Request() req: any, @Body() dto: UpdatePostDto) {
    return this.postsService.update(id, req.user.id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remover post (somente dono)' })
  remove(@Param('id') id: string, @Request() req: any) {
    return this.postsService.remove(id, req.user.id);
  }
}
