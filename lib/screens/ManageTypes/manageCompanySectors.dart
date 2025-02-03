import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/providers/companyProvider.dart';
import 'package:punch/providers/textConroller.dart';
import 'package:punch/widgets/routes/manageType.dart';


class ManageCompanySectorsPage extends StatelessWidget {
  ManageCompanySectorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);
    final notifier = Provider.of<TextControllerNotifier>(context);
    return ManageTypesPage(
      title: 'Company Sector Types',
      inputLabel: 'Company Sector Description',
      items: companyProvider.companySectors,
      onItemAdded: () {
        if (notifier.descriptionController.text.isNotEmpty) {
          companyProvider
              .addCompanySector(notifier.descriptionController);
        }
      },
      onItemUpdated: () {
        if (notifier.selectedId != null) {
          if (notifier.descriptionController.text.isNotEmpty) {
            companyProvider.updateCompanySector(
                notifier.selectedId!, notifier.descriptionController, () {
              notifier.descriptionController.clear();
            });
          }
        }
      },
      onItemDeleted: (id) async {
        await companyProvider.deleteCompanySector(context, id);
      },
    );
  }
}

