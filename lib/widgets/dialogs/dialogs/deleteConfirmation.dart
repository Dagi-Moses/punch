import 'package:flutter/material.dart';

Future<dynamic> deleteItemDialog(
    BuildContext context, String itemName, VoidCallback onDelete) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Column(
            children: [
              Icon(Icons.warning_outlined, size: 36, color: Colors.red),
              SizedBox(height: 20),
              Text("Confirm Deletion"),
            ],
          ),
        ),
        content: Container(
          height: 70,
          child: Column(
            children: [
              Text(
                "Are you sure you want to delete '$itemName'?",
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.delete,
                      size: 14,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: onDelete,
                    label: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
