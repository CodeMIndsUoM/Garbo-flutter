import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:garbo_swms/core/constants/cloudinary_constants.dart';

class CloudinaryUploadService {
  Future<String> uploadCollectionPhoto(File imageFile) async {
    if (!CloudinaryConstants.isConfigured) {
      throw Exception(
        'Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET using --dart-define.',
      );
    }

    final cloudinary = CloudinaryPublic(
      CloudinaryConstants.cloudName,
      CloudinaryConstants.uploadPreset,
      cache: false,
    );

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        imageFile.path,
        resourceType: CloudinaryResourceType.Image,
        folder: 'garbo/collection-completions',
      ),
    );

    return response.secureUrl;
  }
}
