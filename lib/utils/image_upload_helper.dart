import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUploadHelper {
  static Future<Map<String, dynamic>> prepareImageForUpload(String imagePath) async {
    if (kIsWeb) {
      // For web, convert image to base64
      final imageBytes = await XFile(imagePath).readAsBytes();
      final base64String = base64Encode(imageBytes);
      return {
        'isWeb': true,
        'data': base64String,
      };
    } else {
      // For mobile, use File
      return {
        'isWeb': false,
        'data': File(imagePath),
      };
    }
  }
}