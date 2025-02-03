import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/providers/textConroller.dart';
import 'package:punch/providers/titleProvider.dart';
import 'package:punch/widgets/routes/manageType.dart';


class ManageTitlePage extends StatelessWidget {
  ManageTitlePage({Key? key}) : super(key: key);
  TextEditingController _descriptionController = TextEditingController();
  int? _selectedId;
  @override
  Widget build(BuildContext context) {
    final titles = Provider.of<TitleProvider>(context);
    final notifier = Provider.of<TextControllerNotifier>(context);
    return ManageTypesPage(
      title: 'Titles',
      inputLabel: 'Title Description',
      items: titles.titles,
       onItemAdded: () {
        if (notifier.descriptionController.text.isNotEmpty) {
          titles
              .addTitle(notifier.descriptionController);
        }
      },
      onItemUpdated: () {
        if (notifier.selectedId != null) {
          if (notifier.descriptionController.text.isNotEmpty) {
            titles.updateTitle(
                notifier.selectedId!, notifier.descriptionController, () {
              notifier.descriptionController.clear();
            });
          }
        }
      },
      onItemDeleted: (id) async {
        await titles.deleteTitle(context, id);
      },
    );
  }
}
