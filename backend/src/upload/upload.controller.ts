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
  uploadAvatar(@Request() req: any, @UploadedFile() file: Express.Multer.File) {
    return this.uploadService.uploadAvatar(req.user.id, file);
  }

  @Post('posts/:postId/photos')
  @ApiOperation({ summary: 'Upload de foto para um post (máx conforme plano)' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  uploadPostPhoto(
    @Request() req: any,
    @Param('postId') postId: string,
    @UploadedFile() file: Express.Multer.File,
    @Body('caption') caption?: string,
  ) {
    return this.uploadService.uploadPostPhoto(req.user.id, postId, file, caption);
  }

  @Delete('photos/:photoId')
  @ApiOperation({ summary: 'Remover foto de um post' })
  deletePostPhoto(@Param('photoId') photoId: string, @Request() req: any) {
    return this.uploadService.deletePostPhoto(photoId, req.user.id);
  }
}
