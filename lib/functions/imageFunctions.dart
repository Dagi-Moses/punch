import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart'; // For compute

Future<Uint8List?> compressToTargetSizeInBackground(
    Map<String, dynamic> args) async {
  final Uint8List imageBytes = args['imageBytes'];
  final int targetSizeBytes = args['targetSizeBytes'];

  img.Image? image = img.decodeImage(imageBytes);
  if (image == null) return null;

  int quality = 100;
  Uint8List compressedBytes =
      Uint8List.fromList(img.encodeJpg(image, quality: quality));

  while (compressedBytes.length > targetSizeBytes && quality > 10) {
    quality -= 10;
    compressedBytes =
        Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  return compressedBytes;
}

Future<Uint8List?> compressToTargetSize(
    Uint8List imageBytes, int targetSizeKB) async {
  final targetSizeBytes = targetSizeKB * 1024;
  return await compute(
    compressToTargetSizeInBackground,
    {'imageBytes': imageBytes, 'targetSizeBytes': targetSizeBytes},
  );
}
