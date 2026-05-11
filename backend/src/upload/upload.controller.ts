import {
  Body,
  Controller,
  Delete,
  Param,
  Post,
  Request,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UploadService } from './upload.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AuthenticatedRequest } from '../common/interfaces/authenticated-request.interface';
import { BearerToken } from '../common/decorators/bearer-token.decorator';

@ApiTags('Upload')
@Controller('upload')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UploadController {
  constructor(private uploadService: UploadService) {}

  @Post('avatar')
  @ApiOperation({ summary: 'Upload de foto de perfil' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  uploadAvatar(
    @Request() req: AuthenticatedRequest,
    @BearerToken() token: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.uploadService.uploadAvatar(req.user.id, file, token);
  }

  @Post('posts/:postId/photos')
  @ApiOperation({ summary: 'Upload de foto para um post (máx conforme plano)' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  uploadPostPhoto(
    @Request() req: AuthenticatedRequest,
    @Param('postId') postId: string,
    @UploadedFile() file: Express.Multer.File,
    @Body('caption') caption?: string,
  ) {
    return this.uploadService.uploadPostPhoto(req.user.id, postId, file, caption);
  }

  @Delete('photos/:photoId')
  @ApiOperation({ summary: 'Remover foto de um post' })
  deletePostPhoto(@Param('photoId') photoId: string, @BearerToken() token: string) {
    return this.uploadService.deletePostPhoto(photoId, token);
  }

  @Post('portfolio')
  @ApiOperation({ summary: 'Upload de imagem para portfólio do prestador' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  uploadPortfolio(
    @Request() req: AuthenticatedRequest,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.uploadService.uploadPortfolioImage(req.user.id, file);
  }

  @Delete('portfolio/:imageId')
  @ApiOperation({ summary: 'Remover imagem do portfólio' })
  deletePortfolio(@Param('imageId') imageId: string, @Request() req: AuthenticatedRequest) {
    return this.uploadService.deletePortfolioImage(imageId, req.user.id);
  }
}
