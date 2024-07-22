import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/dialogs/add_anniversary_dialog.dart';

import 'package:punch/models/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/widgets/operations.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeIdController = TextEditingController();
  final TextEditingController anniversaryNoController = TextEditingController();
  final TextEditingController placedByNameController = TextEditingController();

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
  List<int> calculatePageSizes(int totalItems) {
    if (totalItems < 10) {
      return [totalItems];
    } else if (totalItems < 50) {
      return [10, totalItems];
    } else if (totalItems < 100) {
      return [10, 20, totalItems];
    } else {
      return [10, 20, 50, 100];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: SpinKitWave(
          color: punchRed,
          size: 50.0,
        ),
      );
    }
    return Expanded(
      flex: 5,
      child: PagedDataTableTheme(
        data: PagedDataTableThemeData(
          horizontalScrollbarVisibility: true,
          verticalScrollbarVisibility: true,
          borderRadius: BorderRadius.circular(10),
          filterBarHeight: 35,
          backgroundColor: Colors.white,
          cellTextStyle: const TextStyle(color: Colors.black),
          chipTheme: ChipThemeData(
              elevation: 4,
              deleteIconColor: Colors.red,
              backgroundColor: Colors.white, // Set background color of the chip
              labelStyle: const TextStyle(
                  color: Colors.black), // Set text color of the chip
              iconTheme: const IconThemeData(color: Colors.black),
              surfaceTintColor: Colors.white,
              color: WidgetStateColor.resolveWith((_) {
                return Colors.white;
              })),
          elevation: 10,
          headerTextStyle: const TextStyle(color: Colors.black),
          footerTextStyle: const TextStyle(color: Colors.black),
        ),
        child: Consumer<AnniversaryProvider>(
            builder: (context, anniversaryProvider, child) {
          final anniversaries = anniversaryProvider.anniversaries;
          anniversaries.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;

            DateTime now = DateTime.now();
            DateTime today = DateTime(now.year, now.month, now.day);

            DateTime aNextAnniversary =
                DateTime(today.year, a.date!.month, a.date!.day);
            DateTime bNextAnniversary =
                DateTime(today.year, b.date!.month, b.date!.day);

            if (aNextAnniversary.isBefore(today)) {
              aNextAnniversary =
                  DateTime(today.year + 1, a.date!.month, a.date!.day);
            }

            if (bNextAnniversary.isBefore(today)) {
              bNextAnniversary =
                  DateTime(today.year + 1, b.date!.month, b.date!.day);
            }

            return aNextAnniversary.compareTo(bNextAnniversary);
          });

          anniversaries.forEach((anniversary) {
            if (anniversary.date != null) {
              DateTime now = DateTime.now();
              DateTime nextAnniversary = DateTime(
                  now.year, anniversary.date!.month, anniversary.date!.day);

              if (nextAnniversary.isBefore(now)) {
                nextAnniversary = DateTime(now.year + 1,
                    anniversary.date!.month, anniversary.date!.day);
              }
            }
          });
          if (anniversaries.isEmpty) {
            return const Center(
              child: SpinKitWave(
                color: punchRed,
                size: 50.0,
              ),
            );
          }
          final pageSizes = calculatePageSizes(anniversaries.length);
          return PagedDataTable<String, Anniversary>(
            controller: tableController,

            configuration: const PagedDataTableConfiguration(),
            pageSizes: pageSizes,

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
            filterBarChild: IconTheme(
              data: const IconThemeData(color: Colors.black),
              child: PopupMenuButton(
                  clipBehavior: Clip.hardEdge,
                  icon: const Icon(Icons.more_vert_outlined),
                  itemBuilder: (context) {
                    return <PopupMenuEntry>[
                      PopupMenuItem(
                        child: const Text("Add anniversary"),
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showAddAnniversaryDialog(context);
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Select Rows"),
                        onTap: () {
                          anniversaryProvider.setBoolValue(true);
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Select all rows"),
                        onTap: () {
                          anniversaryProvider.setBoolValue(true);
                          Future.delayed(Duration.zero, () {
                            tableController.selectAllRows();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          anniversaryProvider.setBoolValue(false);
                        },
                      ),
                      if (anniversaryProvider.isRowsSelected)
                        PopupMenuItem(
                          child: const Text("Delete Selected rows"),
                          onTap: () {},
                        ),
                      PopupMenuItem(
                        child: const Text("Clear filters"),
                        onTap: () {
                          tableController.removeFilters();
                        },
                      ),
                    ];
                  }),
            ),
            // fixedColumnCount: 2,

            columns: [
              if (anniversaryProvider.isRowsSelected) RowSelectorColumn(),
              LargeTextTableColumn(
                title: const Text("Title"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.25), FixedColumnSize(100)),
                getter: (item, index) => item.name ?? "N/A",
                fieldLabel: "Title",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.name = newValue;
                  return true;
                },
              ),
              LargeTextTableColumn(
                title: const Text("Upcoming Date"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(150)),
                getter: (item, index) {
                  if (item.date == null) {
                    return 'N/A';
                  }

                  DateTime now = DateTime.now();
                  DateTime anniversaryDate = item.date!;
                  DateTime today = DateTime(now.year, now.month, now.day);
                  DateTime nextAnniversary = DateTime(
                      today.year, anniversaryDate.month, anniversaryDate.day);

                  if (nextAnniversary.isBefore(today)) {
                    nextAnniversary = DateTime(today.year + 1,
                        anniversaryDate.month, anniversaryDate.day);
                  }

                  Duration difference = nextAnniversary.difference(today);

                  if (difference.inDays == 0) {
                    return "Today";
                  } else if (difference.inDays == 1) {
                    return "Tomorrow";
                  } else if (difference.inDays < 7) {
                    return DateFormat('EEEE')
                        .format(nextAnniversary); // Day of the week
                  } else {
                    return DateFormat('dd/MM/yyyy')
                        .format(nextAnniversary); // Full date
                  }
                },
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.date = newValue as DateTime?;
                  return true;
                },
                fieldLabel: 'Upcoming Date',
              ),
              LargeTextTableColumn(
                title: const Text("Date Placed"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(150)),
                getter: (item, index) => item.date != null
                    ? DateFormat('dd/MM/yyyy').format(item.date!)
                    : 'N/A',
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.date = newValue as DateTime?;
                  return true;
                },
                fieldLabel: 'Date',
              ),
              LargeTextTableColumn(
                title: const Text("Placed By"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.3), FixedColumnSize(280)),
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
                size: const RemainingColumnSize(),
                cellBuilder: (context, item, index) =>
                    operationsWidget(context, item.name ?? "N?A", () {}, () {
                  anniversaryProvider.deleteAnniversary(context,item.id!);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
