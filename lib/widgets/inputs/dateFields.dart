import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EditableDateField extends StatelessWidget {
  final String label;
  final bool isEditing;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController controller;

  const EditableDateField({
    Key? key,
    required this.label,
    required this.isEditing,
    required this.selectedDate,
    required this.onDateChanged,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
        GestureDetector(
          onTap: isEditing
              ? () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    onDateChanged(pickedDate);
                  }
                }
              : null,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: !isEditing,
              cursorColor: Colors.red,
              controller: controller,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget inputDatePicker({
  required DateTime? selectedDate,
  required ValueChanged<DateTime?> onDateSelected,
  required BuildContext context,
  String label = "Date",
}) {
  TextEditingController dateController = TextEditingController(
    text: selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate)
        : '',
  );

  return TextField(
    controller: dateController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null) {
            onDateSelected(pickedDate);
            dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          }
        },
      ),
    ),
  );
}

