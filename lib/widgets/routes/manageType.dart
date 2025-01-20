import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/providers/textConroller.dart';

import 'package:punch/widgets/dialogs/dialogs/deleteConfirmation.dart';
import 'package:punch/widgets/text-form-fields/custom_styled_text_field.dart';

class ManageTypesPage extends StatelessWidget {
  final String title;
  final String inputLabel;
  final VoidCallback onItemAdded;
  final VoidCallback onItemUpdated;
  final Future<void> Function(int id) onItemDeleted;
  final Map<int, String> items;

  const ManageTypesPage({
    Key? key,
    required this.title,
    required this.inputLabel,
    required this.onItemAdded,
    required this.onItemUpdated,
    required this.onItemDeleted,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textControllerNotifier = Provider.of<TextControllerNotifier>(context);
    return Scaffold(
       appBar: AppBar(
        backgroundColor: punchRed,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Manage $title", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
       ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        //flex: 3,
                        child: CustomInputTextField(
                          label: inputLabel,
                          controller:
                              textControllerNotifier.descriptionController,
                        ),
                      ),
                      Visibility(
                        visible: textControllerNotifier
                                .descriptionController.text.isNotEmpty ||
                            textControllerNotifier.selectedId != null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: textControllerNotifier
                                  .descriptionText.isNotEmpty,
                              child: CustomButton(
                                label: textControllerNotifier.selectedId == null
                                    ? 'Add'
                                    : 'Update',
                                onPressed: () {
                                  if (textControllerNotifier.selectedId ==
                                      null) {
                                    onItemAdded();
                                  } else {
                                    onItemUpdated();
                                    textControllerNotifier.selectedId = null;
                                    textControllerNotifier.descriptionController
                                        .clear();
                                  }
                                },
                                color: Colors.green,
                              ),
                            ),
                            Visibility(
                              visible:
                                  textControllerNotifier.selectedId != null,
                              child: CustomButton(
                                label: 'Cancel',
                                onPressed: () {
                                  textControllerNotifier.selectedId = null;
                                  textControllerNotifier.descriptionController
                                      .clear();
                                },
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                 Text(
                    'Existing $title',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: punchRed),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        int typeId = items.keys.elementAt(index);
                        String description = items[typeId]!;

                        return CustomListItem(
                          title: description,
                          onEdit: () {
                            textControllerNotifier.selectedId = typeId;
                            textControllerNotifier.descriptionController.text =
                                description;
                          },
                          onDelete: () async {
                            deleteItemDialog(context, description, () async {
                              await onItemDeleted(typeId);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CustomListItem extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomListItem({
    Key? key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
