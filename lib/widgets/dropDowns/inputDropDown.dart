import 'package:flutter/material.dart';

class CustomInputDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final double fontSize;
  final double borderRadius;

  const CustomInputDropdown({
    Key? key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.fontSize = 14.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        items: items.entries.map((entry) {
          return DropdownMenuItem<T>(
            value: entry.key,
            child: Text(
              entry.value,
              overflow: TextOverflow.clip,
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
