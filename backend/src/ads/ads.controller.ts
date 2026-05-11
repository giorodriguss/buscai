import { Controller, Get, Param, Post } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AdsService } from './ads.service';

@ApiTags('Ads')
@Controller('ads')
export class AdsController {
  constructor(private adsService: AdsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar anúncios ativos' })
  @ApiResponse({ status: 200, description: 'Lista de anúncios ativos' })
  findActive() {
    return this.adsService.findActive();
  }

  @Post(':id/impression')
  @ApiOperation({ summary: 'Registrar impressão de anúncio' })
  @ApiResponse({ status: 200, description: 'Impressão registrada' })
  @ApiResponse({ status: 404, description: 'Anúncio não encontrado' })
  trackImpression(@Param('id') id: string) {
    return this.adsService.trackImpression(id);
  }

  @Post(':id/click')
  @ApiOperation({ summary: 'Registrar clique em anúncio' })
  @ApiResponse({ status: 200, description: 'Clique registrado' })
  @ApiResponse({ status: 404, description: 'Anúncio não encontrado' })
  trackClick(@Param('id') id: string) {
    return this.adsService.trackClick(id);
  }
}
