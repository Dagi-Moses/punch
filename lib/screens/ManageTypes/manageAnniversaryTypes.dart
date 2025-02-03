import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/textConroller.dart';
import 'package:punch/widgets/routes/manageType.dart';

class ManageAnniversaryTypesPage extends StatelessWidget {
  ManageAnniversaryTypesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
    final notifier = Provider.of<TextControllerNotifier>(context);
    return ManageTypesPage(
      title: 'Anniversary Types',
      inputLabel: 'Anniversary Description',
      items: anniversaryProvider.anniversaryTypes,
      onItemAdded: () {
        if (notifier.descriptionController.text.isNotEmpty) {
          anniversaryProvider
              .addAnniversaryType(notifier.descriptionController);
        }
      },
      onItemUpdated: () {
        if (notifier.selectedId != null) {
          if (notifier.descriptionController.text.isNotEmpty) {
            anniversaryProvider.updateAnniversaryType(
                notifier.selectedId!, notifier.descriptionController, () {
              notifier.descriptionController.clear();
            });
          }
        }
      },
      onItemDeleted: (id) async {
        await anniversaryProvider.deleteAnniversaryType(context, id);
      },
    );
  }
}

// class ManageAnniversaryTypesPage extends StatefulWidget {
//   @override
//   _ManageAnniversaryTypesPageState createState() =>
//       _ManageAnniversaryTypesPageState();
// }

// class _ManageAnniversaryTypesPageState
//     extends State<ManageAnniversaryTypesPage> {
//   TextEditingController descriptionController = TextEditingController();
//   int? _selectedId;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//          automaticallyImplyLeading: false,
//         title: const Text('Manage Anniversary Types'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Consumer<AnniversaryProvider>(
//             builder: (context, anniversaryProvider, child) {
//           return Column(
//             children: [
//               TextField(
//                 controller: descriptionController,
//                 decoration: const InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold)),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     style:
//                         ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                     onPressed: () {
//                       if (_selectedId == null) {
//                         anniversaryProvider.addAnniversaryType(
//                           descriptionController,
//                         );
//                       } else {
//                         anniversaryProvider.updateAnniversaryType(
//                             _selectedId!, descriptionController, () {
//                           setState(() {
//                             _selectedId = null;
//                           });
//                         });
//                       }
//                     },
//                     child: Text(
//                       _selectedId == null ? 'Add' : 'Update',
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                   ),
//                   if (_selectedId != null)
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _selectedId = null;
//                           descriptionController.clear();
//                         });
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: anniversaryProvider.anniversaryTypes.length,
//                   itemBuilder: (context, index) {
//                     int typeId = anniversaryProvider.anniversaryTypes.keys
//                         .elementAt(index);
//                     String description =
//                         anniversaryProvider.anniversaryTypes[typeId]!;

//                     return ListTile(
//                       title: Text(description),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(
//                               Icons.edit,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _selectedId = typeId;
//                                 descriptionController.text = description;
//                               });
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.delete,
//                               color: Colors.red,
//                             ),
//                             onPressed: () {
//                               deleteItemDialog(context, description, () async {
//                               await anniversaryProvider
//                                     .deleteAnniversaryType(context,typeId);
//                                     setState(() {
                                      
//                                     });
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
