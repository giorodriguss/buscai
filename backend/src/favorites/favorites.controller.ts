import { Controller, Delete, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BearerToken } from '../common/decorators/bearer-token.decorator';

@ApiTags('Favorites')
@Controller('favorites')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FavoritesController {
  constructor(private favoritesService: FavoritesService) {}

  @Post(':postId')
  @ApiOperation({ summary: 'Adicionar post aos favoritos' })
  @ApiResponse({ status: 201, description: 'Post adicionado aos favoritos' })
  @ApiResponse({ status: 400, description: 'Post já está nos favoritos' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  @ApiResponse({ status: 404, description: 'Post não encontrado' })
  add(@BearerToken() token: string, @Param('postId') postId: string) {
    return this.favoritesService.add(postId, token);
  }

  @Delete(':postId')
  @ApiOperation({ summary: 'Remover post dos favoritos' })
  @ApiResponse({ status: 200, description: 'Post removido dos favoritos' })
  @ApiResponse({ status: 400, description: 'Post não está nos favoritos' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  remove(@BearerToken() token: string, @Param('postId') postId: string) {
    return this.favoritesService.remove(postId, token);
  }

  @Get()
  @ApiOperation({ summary: 'Listar meus favoritos' })
  @ApiResponse({ status: 200, description: 'Lista de favoritos do usuário autenticado' })
  @ApiResponse({ status: 401, description: 'Token ausente ou inválido' })
  findMine(@BearerToken() token: string) {
    return this.favoritesService.findByUser(token);
  }
}
