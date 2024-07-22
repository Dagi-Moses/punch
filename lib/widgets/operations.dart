import 'package:flutter/material.dart';

Widget operationsWidget(
  BuildContext context,
  String itemName,
  VoidCallback onView,
  VoidCallback onDelete,
) {
  return Row(
    children: [
      TextButton(
        child: Text('View', style: TextStyle(color: Colors.green)),
        onPressed: onView,
      ),
      SizedBox(width: 6),
      TextButton(
        child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
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
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            label: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton.icon(
                            icon: Icon(
                              Icons.delete,
                              size: 14,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: onDelete,
                            label: Text(
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
        },
      ),
    ],
  );
}
