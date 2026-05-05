import { Controller, Delete, Get, Param, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Favorites')
@Controller('favorites')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FavoritesController {
  constructor(private favoritesService: FavoritesService) {}

  @Post(':postId')
  @ApiOperation({ summary: 'Adicionar post aos favoritos' })
  add(@Request() req: any, @Param('postId') postId: string) {
    return this.favoritesService.add(req.user.id, postId);
  }

  @Delete(':postId')
  @ApiOperation({ summary: 'Remover post dos favoritos' })
  remove(@Request() req: any, @Param('postId') postId: string) {
    return this.favoritesService.remove(req.user.id, postId);
  }

  @Get()
  @ApiOperation({ summary: 'Listar meus favoritos' })
  findMine(@Request() req: any) {
    return this.favoritesService.findByUser(req.user.id);
  }
}
