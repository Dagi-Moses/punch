import 'dart:typed_data';
import 'package:flutter/material.dart';

class EditableImagePicker extends StatelessWidget {
  final String label;
  final bool isEditing;
  final Uint8List? image;
  final Future<Uint8List?> Function()? onPickImage;
  final VoidCallback? onRemoveImage;
  final ValueChanged<Uint8List>? onImageChanged;
  final VoidCallback? onDownloadImage;

  const EditableImagePicker({
    Key? key,
    required this.label,
    required this.isEditing,
    this.image,
    this.onPickImage,
    this.onRemoveImage,
    this.onImageChanged,
    this.onDownloadImage,
  }) : super(key: key);

  BoxDecoration _boxDecoration({DecorationImage? decorationImage}) {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300, width: 1.5),
      borderRadius: BorderRadius.circular(12),
      image: decorationImage,
      color: Colors.grey.shade200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: isEditing
              ? () async {
                  if (onPickImage != null) {
                    final pickedImage = await onPickImage!();
                    if (pickedImage != null && onImageChanged != null) {
                      onImageChanged!(pickedImage);
                    }
                  }
                }
              : () {
                  if (image != null && onDownloadImage != null) {
                    onDownloadImage!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No image to download.')),
                    );
                  }
                },
          child: Container(
            height: 500,
            width: double.infinity,
            decoration: _boxDecoration(
              decorationImage: image != null
                  ? DecorationImage(
                      image: MemoryImage(image!),
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
            child: image == null
                ? const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 15),
        if (isEditing && image != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  if (onPickImage != null) {
                    final pickedImage = await onPickImage!();
                    if (pickedImage != null && onImageChanged != null) {
                      onImageChanged!(pickedImage);
                    }
                  }
                },
                icon: const Icon(Icons.upload),
                label: const Text("Change"),
              ),
              ElevatedButton.icon(
                onPressed: onRemoveImage,
                icon: const Icon(Icons.delete),
                label: const Text("Remove"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
