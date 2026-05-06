import { Controller, Get, Param, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdsService } from './ads.service';

@ApiTags('Ads')
@Controller('ads')
export class AdsController {
  constructor(private adsService: AdsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar anúncios ativos' })
  findActive() {
    return this.adsService.findActive();
  }

  @Post(':id/impression')
  @ApiOperation({ summary: 'Registrar impressão de anúncio' })
  trackImpression(@Param('id') id: string) {
    return this.adsService.trackImpression(id);
  }

  @Post(':id/click')
  @ApiOperation({ summary: 'Registrar clique em anúncio' })
  trackClick(@Param('id') id: string) {
    return this.adsService.trackClick(id);
  }
}
