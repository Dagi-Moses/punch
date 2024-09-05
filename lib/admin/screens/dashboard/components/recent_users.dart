import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/core/utils/colorful_tag.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';

class RecentUsers extends StatelessWidget {
  const RecentUsers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnniversaryProvider>(
      builder: (context, anniversaryProvider, child) {
        final anniversaries = anniversaryProvider.anniversaries;

        return Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Anniversaries",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    horizontalMargin: 0,
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(
                        label: Text("Title"),
                      ),
                      DataColumn(
                        label: Text("Placed By"),
                      ),
                      DataColumn(
                        label: Text("Date"),
                      ),
                      DataColumn(
                        label: Text("Id"),
                      ),
                      DataColumn(
                        label: Text("Operation"),
                      ),
                    ],
                    rows: List.generate(
                      anniversaries.length,
                      (index) =>
                          recentUserDataRow(anniversaries[index], context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

DataRow recentUserDataRow(Anniversary anniversary, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            TextAvatar(
              size: 35,
              backgroundColor: Colors.white,
              textColor: Colors.white,
              fontSize: 14,
              upperCase: true,
              numberLetters: 1,
              shape: Shape.Rectangle,
              text: anniversary.name!,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                anniversary.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      DataCell(Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: getRoleColor(anniversary.paperId).withOpacity(.2),
          border: Border.all(color: getRoleColor(anniversary.paperId)),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Text(anniversary.paperId.toString()),
      )),
      DataCell(Text(anniversary.date.toString())),
      DataCell(Text(anniversary.placedByName!)),
      DataCell(
        Row(
          children: [
            TextButton(
              child: Text('View', style: TextStyle(color: punchRed)),
              onPressed: () {},
            ),
            SizedBox(
              width: 6,
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Center(
                        child: Column(
                          children: [
                            Icon(Icons.warning_outlined,
                                size: 36, color: Colors.red),
                            SizedBox(height: 20),
                            Text("Confirm Deletion"),
                          ],
                        ),
                      ),
                      content: Container(
                        color: secondaryColor,
                        height: 70,
                        child: Column(
                          children: [
                            Text(
                                "Are you sure want to delete '${anniversary.name}'?"),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.close, size: 14),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  label: Text("Cancel"),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.delete, size: 14),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    // Call delete function here
                                  },
                                  label: Text("Delete"),
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
        ),
      ),
    ],
  );
}
