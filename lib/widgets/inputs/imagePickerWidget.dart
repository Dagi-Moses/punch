import 'dart:typed_data';

import 'package:flutter/material.dart';
class ImagePickerWidget extends StatelessWidget {
  final VoidCallback onTap; // Callback for the image picker action
  final Uint8List? imageBytes; // The image to display if available
  final bool isLoading; // Loading state
  final String placeholderText; // Placeholder text for the image picker
  final double aspectRatio; // Aspect ratio of the image container
  final double borderRadius; // Border radius for the container
  final double height; // Height for the placeholder container
  final Color borderColor; // Border color for the container

  const ImagePickerWidget({
    Key? key,
    required this.onTap,
    this.imageBytes,
    this.isLoading = false,
    this.placeholderText = "Tap to upload image",
    this.aspectRatio = 3 / 2,
    this.borderRadius = 8.0,
    this.height = 200.0,
    this.borderColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            children: [
              if (imageBytes != null)
                Image.memory(
                  imageBytes!,
                  fit: BoxFit.contain,
                )
              else
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Center(
                    child: Text(
                      placeholderText,
                      style: TextStyle(color: borderColor),
                    ),
                  ),
                ),
              if (isLoading)
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
