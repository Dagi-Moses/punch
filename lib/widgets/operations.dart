import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/widgets/dialogs/dialogs/deleteConfirmation.dart';

Widget operationsWidget(
  BuildContext context,
  String itemName,
  VoidCallback onView,
  VoidCallback onDelete,
) {
  final auth = Provider.of<AuthProvider>(context);

  final isUser = auth.user?.loginId == UserRole.user;

  return Center(
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          onPressed: onView,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding
          ),
          child: const Text('View', style: TextStyle(color: Colors.green)),
        ),
        if (!isUser)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, // Remove default padding
            ),
            child:
                const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              deleteItemDialog(context, itemName, onDelete);
            },
          ),
      ],
    ),
  );
}
