import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/core/utils/colorful_tag.dart';
import 'package:punch/models/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';



class AnniversaryTable2 extends StatefulWidget {
  const AnniversaryTable2({Key? key}) : super(key: key);

  @override
  State<AnniversaryTable2> createState() => _AnniversaryTable2State();
}

class _AnniversaryTable2State extends State<AnniversaryTable2> {
  final tableController = PagedDataTableController<String, Anniversary>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting(
        'en'); 
    setState(() {
      _isInitialized = true;
    });
  }
  @override
  Widget build(BuildContext context) {
      if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Consumer<AnniversaryProvider>(
      builder: (context, anniversaryProvider, child) {
        final anniversaries = anniversaryProvider.anniversaries;
         if (anniversaries.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
       
              return   PagedDataTableTheme(
                data: PagedDataTableThemeData(
                  selectedRow: const Color(0xFFCE93D8),
                  rowColor: (index) => index.isEven ? Colors.purple[50] : null,
                ),
                child: PagedDataTable <String, Anniversary>(
                            //  initialPageSize: 100,
                  configuration: const PagedDataTableConfiguration(),
                  pageSizes: const [10, 20, 50, 100],
                              controller: tableController,
                           columns: [
                               RowSelectorColumn(),
                    TableColumn(
              
                      format: AlignColumnFormat(alignment: Alignment.center),
                      title: const Text("Title"),
                      cellBuilder: (context, item, index) => Expanded(
                        child: Text(item.name!,  style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      
                    ),
                    TableColumn(
                      
                      title: Text("Date", overflow: TextOverflow.visible,
                      ),
                      cellBuilder: (context, item, index) => Expanded(
                        child: Text(
                           DateFormat('ddMMyyyy').format(item.date!), overflow: TextOverflow.visible,
                          ),
                      ),
                    ),
                    TableColumn(
                     
                      title: const Text("Type Id"),
                      cellBuilder: (context, item, index) => Text(item.anniversaryTypeId.toString()),
                    ),
                    TableColumn(
                     
                      title: const Text("Placed By"),
                      cellBuilder: (context, item, index) => Text(item.placedByName!),
                    ),
                   
                  ],
                  fetcher: (int pageSize, SortModel? sortModel,
                      FilterModel filterModel, String? pageToken) {
                    try {
                      int pageIndex = int.parse(pageToken ?? "0");
                
                      List<Anniversary> data = anniversaries
                          .skip(pageSize * pageIndex)
                          .take(pageSize)
                          .toList();
                
                      String? nextPageToken = (data.length == pageSize)
                          ? (pageIndex + 1).toString()
                          : null;
                          print(' no single Error fetching page: ${data}');
                       return (data, nextPageToken);
                       
                    } catch (e) {
                      print('Error fetching page: $e');
                      return Future.error('Error fetching page: $e');
                    }
                  },
                     fixedColumnCount: 2,
                 
                             
                ),
              );
            },
          ),
        );
      },
    );
  }
}

DataRow recentUserDataRow(Anniversary anniversary, BuildContext context) {
  final DateFormat dateFormat = DateFormat.yMMMd();
  return DataRow(
    cells: [
      DataCell(
        Text(
          anniversary.name!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DataCell(
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: getRoleColor(anniversary.paperId).withOpacity(.2),
              border: Border.all(color: getRoleColor(anniversary.paperId)),
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Text(anniversary.paperId.toString()),
          ),
        ),
      ),
      DataCell(Text(dateFormat.format(anniversary.date!))),
      DataCell(Text(anniversary.placedByName!)),
      DataCell(
        Row(
          children: [
            TextButton(
              child: const Text('View', style: TextStyle(color: greenColor)),
              onPressed: () {
                // Handle view action
              },
            ),
            const SizedBox(width: 6),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Center(
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.close, size: 14),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  label: const Text("Cancel"),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.delete, size: 14),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    // Call delete function here
                                  },
                                  label: const Text("Delete"),
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
