import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
Future<Uint8List?> compressToTargetSize(
    Uint8List imageBytes, int targetSizeKB) async {
  int width = 1200; // Starting width
  int height = 1200; // Starting height
  Uint8List? compressedImage;

  while (true) {
    compressedImage = await FlutterImageCompress.compressWithList(
   format: CompressFormat.webp,

      imageBytes,
      minWidth: width,
      minHeight: height,
      quality: 100, // Maintain high quality
    );

    final sizeKB = compressedImage.lengthInBytes / 1024;
    if (sizeKB <= targetSizeKB) break;

    // Reduce dimensions by 10% iteratively
    width = (width * 0.9).round();
    height = (height * 0.9).round();
    print("Original Size: ${imageBytes.lengthInBytes / 1024} KB");
    print("Compressed Size: ${compressedImage!.lengthInBytes / 1024} KB");

  }

  return compressedImage;
}


