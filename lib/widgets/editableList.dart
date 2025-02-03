import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EditableList extends StatefulWidget {
  final String title;
  final List<String> items;
  final bool isEditing;
  final Function(String) onAdd;
  final Function(String) onDelete;
  final Function(String, String) onEdit;

  const EditableList({
    Key? key,
    required this.title,
    required this.items,
    required this.isEditing,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditableList> createState() => _EditableListState();
}

class _EditableListState extends State<EditableList> {

  late TextEditingController itemController;
  late FocusNode focusNode;
 ValueNotifier<bool> isExpanded = ValueNotifier(false);
  ValueNotifier<bool> isSelectionMode = ValueNotifier(false);
  Set<String> selectedItems = {}; // Track selected items


  @override
  void initState() {
    super.initState();
    itemController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    itemController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
            fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        
        widget.isEditing && widget.items.isNotEmpty?
            Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder<bool>(
                valueListenable: isSelectionMode,
                builder: (context, selectionMode, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => isSelectionMode.value = !selectionMode,
                        icon: Icon(
                          selectionMode
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.blue,
                        ),
                        label: Text(
                          selectionMode ? "Done" : "Select",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      selectionMode
                          ? ElevatedButton(
                              onPressed: () {
                                for (var item in selectedItems) {
                                  widget.onDelete(item);
                                }
                                selectedItems.clear();
                                isSelectionMode.value = false;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Delete Selected"),
                            )
                          : const SizedBox(),
                    ],
                  );
                },
              ),
            ): const SizedBox(),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: isExpanded,
            builder: (context, expanded, _) {
              final visibleItems = expanded ? widget.items : widget.items.take(1).toList();

              return GestureDetector(
                onTap: () => isExpanded.value = !expanded,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          return Column(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: isSelectionMode,
                                builder: (context, selectionMode, _) {
                                  return Slidable(
                                    closeOnScroll: true,
                                    key: ValueKey(item),
                                    enabled: widget.isEditing,
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            TextEditingController
                                                editController =
                                                TextEditingController(
                                                    text: item);
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Edit ${widget.title}"),
                                                  content: TextField(
                                                    controller: editController,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          "Enter new name",
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        String newName =
                                                            editController.text
                                                                .trim();
                                                        if (newName
                                                            .isNotEmpty) {
                                                          widget.onEdit(item, newName);
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                      ),
                                                      child: const Text("Save"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          icon: Icons.edit,
                                          label: 'Edit',
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Delete ${widget.title}"),
                                                  content: Text(
                                                    "Are you sure you want to delete \"$item\"?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        widget.onDelete(item);
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                      child:
                                                          const Text("Delete"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: selectionMode
                                          ? Checkbox(
                                              value:
                                                  selectedItems.contains(item),
                                              onChanged: (isSelected) {
                                                if (isSelected == true) {
                                                  selectedItems.add(item);
                                                } else {
                                                  selectedItems.remove(item);
                                                }
                                                isSelectionMode
                                                    .notifyListeners();
                                              },
                                            )
                                          : null,
                                      title: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        if (selectionMode) {
                                          if (selectedItems.contains(item)) {
                                            selectedItems.remove(item);
                                          } else {
                                            selectedItems.add(item);
                                          }
                                          isSelectionMode.notifyListeners();
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                              if (index < visibleItems.length - 1)
                                const Divider(height: 1, color: Colors.grey),
                            ],
                          );
                        },
                      ),
                      if (widget.items.length > 1)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            expanded ? "Show Less" : "Show All",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextField(
                focusNode: focusNode,
                controller: itemController,
                decoration: InputDecoration(
                  hintText: "Add new ${widget.title}",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.onAdd(value);
                    itemController.clear();
                    focusNode.requestFocus();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
