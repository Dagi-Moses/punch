import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/models/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/widgets/operations.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('en');
    setState(() {
      _isInitialized = true;
    });
  }

  final tableController = PagedDataTableController<String, Anniversary>();

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Expanded(
      flex: 5,
      child: PagedDataTableTheme(
        data: PagedDataTableThemeData(
          selectedRow: const Color(0xFFCE93D8),
          rowColor: (index) => index.isEven ? Colors.purple[50] : null,
        ),
        child: Consumer<AnniversaryProvider>(
            builder: (context, anniversaryProvider, child) {
          final anniversaries = anniversaryProvider.anniversaries;
          if (anniversaries.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return PagedDataTable<String, Anniversary>(
            controller: tableController,
            // initialPageSize: 100,
            configuration: const PagedDataTableConfiguration(),
            pageSizes: const [10, 20, 50, 100],
            fetcher: (pageSize, sortModel, filterModel, pageToken) async {
              try {
                int pageIndex = int.parse(pageToken ?? "0");

                List<Anniversary> data = anniversaries
                    .skip(pageSize * pageIndex)
                    .take(pageSize)
                    .toList();

                String? nextPageToken = (data.length == pageSize)
                    ? (pageIndex + 1).toString()
                    : null;

                return (data, nextPageToken);
              } catch (e) {
                return Future.error('Error fetching page: $e');
              }
            },

            filters: [
              TextTableFilter(
                id: "content",
                chipFormatter: (value) => 'Content has "$value"',
                name: "Content",
              ),
              DateTimePickerTableFilter(
                id: "date",
                name: "Select Date",
                chipFormatter: (value) => 'Anniversaries on "$value"',
                enabled: true,
                dateFormat: DateFormat('dd/MM/yyyy'),
                initialValue: DateTime.now(),
                firstDate: DateTime(1880),
                lastDate: DateTime(DateTime.now().year + 1),
              ),
              DateRangePickerTableFilter(
                id: "dateRange",
                name: "Select Date Range",
                chipFormatter: (value) =>
                    'Anniversaries from "${value?.start != null ? DateFormat('dd/MM/yyyy').format(value!.start) : 'N/A'} to ${value?.end != null ? DateFormat('dd/MM/yyyy').format(value!.end) : 'N/A'}"',
                enabled: true,
                initialValue:
                    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                firstDate: DateTime(1880),
                lastDate: DateTime(DateTime.now().year + 1),
                formatter: (dateRange) {
                  return 'Anniversaries from "${DateFormat('dd/MM/yyyy').format(dateRange.start)} to ${DateFormat('dd/MM/yyyy').format(dateRange.end)}"';
                },
              ),
            ],
            filterBarChild: PopupMenuButton(
              icon: const Icon(Icons.more_vert_outlined),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: const Text("Print selected rows"),
                  onTap: () {
                    debugPrint(tableController.selectedRows.toString());
                    debugPrint(tableController.selectedItems.toString());
                  },
                ),
                PopupMenuItem(
                  child: const Text("Select random row"),
                  onTap: () {
                    final index = Random().nextInt(tableController.totalItems);
                    tableController.selectRow(index);
                  },
                ),
                PopupMenuItem(
                  child: const Text("Select all rows"),
                  onTap: () {
                    tableController.selectAllRows();
                  },
                ),
                PopupMenuItem(
                  child: const Text("Unselect all rows"),
                  onTap: () {
                    tableController.unselectAllRows();
                  },
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  child: const Text("Remove first row"),
                  onTap: () {
                    tableController.removeRowAt(0);
                  },
                ),
                PopupMenuItem(
                  child: const Text("Remove last row"),
                  onTap: () {
                    tableController.removeRowAt(tableController.totalItems - 1);
                  },
                ),
                PopupMenuItem(
                  child: const Text("Remove random row"),
                  onTap: () {
                    final index = Random().nextInt(tableController.totalItems);
                    tableController.removeRowAt(index);
                  },
                ),
                PopupMenuItem(
                  child: const Text("Replace first"),
                  onTap: () {
                    tableController.replace(
                        0, Anniversary(anniversaryTypeId: 1));
                  },
                ),
                PopupMenuItem(
                  child: const Text("Insert first"),
                  onTap: () {
                    tableController.insertAt(
                        0, Anniversary(anniversaryTypeId: 1));
                  },
                ),
                PopupMenuItem(
                  child: const Text("Insert last"),
                  onTap: () {
                    tableController.insert(Anniversary(anniversaryTypeId: 1));
                  },
                ),
                const PopupMenuDivider(),
               
                PopupMenuItem(
                  child: const Text("Remove filter"),
                  onTap: () {
                    tableController.removeFilter("authorGender");
                  },
                ),
                PopupMenuItem(
                  child: const Text("Clear filters"),
                  onTap: () {
                    tableController.removeFilters();
                  },
                ),
              ],
            ),
            //  fixedColumnCount: 2,
            columns: [
              // RowSelectorColumn(
              // ),
              TableColumn(
                title: const Text("Title"),
                cellBuilder: (context, item, index) => Text(item.name!),

                //size: const FixedColumnSize(300),
                size: const FractionalColumnSize(.2),
              ),
              TableColumn(
                title: const Text("Date"),
                cellBuilder: (context, item, index) => Text(
                  DateFormat('dd/MM/yyyy').format(item.date!),
                ),
                sortable: true,
                id: "date",
                size: const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(100)),
              ),
              TableColumn(
                title: const Text("Type Id"),
                cellBuilder: (context, item, index) =>
                    Text(item.anniversaryTypeId.toString()),
                size: const FixedColumnSize(100),
              ),
              TextTableColumn(
                title: const Text("Number"),
                format: const NumericColumnFormat(),
                // cellBuilder: (context, item, index) => Text(item.number.toString()),
                size: const MaxColumnSize(
                    FixedColumnSize(100), FractionalColumnSize(.1)),
                getter: (item, index) => item.anniversaryNo.toString(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.anniversaryNo = int.parse(newValue);
                  return true;
                },
              ),
              LargeTextTableColumn(
                title: const Text("Placed By"),
                size: const RemainingColumnSize(),
                getter: (item, index) => item.placedByName,
                fieldLabel: "Placed By",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.associates = newValue;
                  return true;
                },
              ),
              TableColumn(
                title: const Text("Operations"),
                cellBuilder: (context, item, index) =>
                    operationsWidget(context, item.name!, () {}, () {}),
              ),
            ],
          );
        }),
      ),
    );
  }
}
