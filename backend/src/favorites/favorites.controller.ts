import { Controller, Delete, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
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
  add(@BearerToken() token: string, @Param('postId') postId: string) {
    return this.favoritesService.add(postId, token);
  }

  @Delete(':postId')
  @ApiOperation({ summary: 'Remover post dos favoritos' })
  remove(@BearerToken() token: string, @Param('postId') postId: string) {
    return this.favoritesService.remove(postId, token);
  }

  @Get()
  @ApiOperation({ summary: 'Listar meus favoritos' })
  findMine(@BearerToken() token: string) {
    return this.favoritesService.findByUser(token);
  }
}
