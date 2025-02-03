import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomEditableDropdown<T> extends StatelessWidget {
  final String label;
  final ValueListenable<T?> valueListenable;
  final Map<T, String> items;
  final bool isEditing;
  final ValueChanged<T?> onChanged;

  // Optional custom item builder
  final DropdownMenuItem<T> Function(T key, String value)? itemBuilder;

  const CustomEditableDropdown({
    Key? key,
    required this.label,
    required this.valueListenable,
    required this.items,
    required this.isEditing,
    required this.onChanged,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<T>(
                  borderRadius: BorderRadius.circular(10),
                  dropdownColor: Colors.white,
                  value: value,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                  ),
                  items: items.keys.map((key) {
                    final itemValue = items[key]!;
                    return itemBuilder != null
                        ? itemBuilder!(key, itemValue) // Use custom itemBuilder
                        : DropdownMenuItem<T>(
                            value: key,
                            enabled: isEditing,
                            child: Text(itemValue),
                          );
                  }).toList(),
                  onChanged: isEditing ? onChanged : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
