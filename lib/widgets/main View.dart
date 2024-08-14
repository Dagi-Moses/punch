import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/dialogs/add_anniversary_dialog.dart';
import 'package:punch/constants/constants.dart';

import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/screens/anniversaryView.dart';
import 'package:punch/widgets/footer.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tableController.removeFilters();
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
          cellPadding: const EdgeInsets.all(0),
          horizontalScrollbarVisibility: true,
          borderRadius: BorderRadius.circular(10),
          filterBarHeight: 35,
          backgroundColor: Colors.white,
          cellTextStyle: const TextStyle(
            color: Colors.black,
          ),
          elevation: 10,
          headerTextStyle: const TextStyle(color: Colors.black),
          footerTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        child: Consumer<AnniversaryProvider>(
            builder: (context, anniversaryProvider, child) {
          List<Anniversary> anniversaries = anniversaryProvider.anniversaries;
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
            fixedColumnCount: 1,

            controller: tableController,

            configuration: const PagedDataTableConfiguration(),
            pageSizes: pageSizes,

            fetcher: (pageSize, sortModel, filterModel, pageToken) async {
              try {
                int pageIndex = int.parse(pageToken ?? "0");

                // Filter data based on filterModel
                List<Anniversary> filteredData =
                    anniversaries.where((anniversary) {
                  // Text filter
                  if (filterModel['content'] != null &&
                      !anniversary.name!
                          .toLowerCase()
                          .contains(filterModel['content'].toLowerCase())) {
                    return false;
                  }

                  if (filterModel['date'] != null) {
                    DateTime selectedDate = filterModel['date'];
                    DateTime now = DateTime.now();

                    if (anniversary.date == null ||
                        DateTime(
                              now.year,
                              anniversary.date!.month,
                              anniversary.date!.day,
                            ).compareTo(DateTime(
                              now.year,
                              selectedDate.month,
                              selectedDate.day,
                            )) !=
                            0) {
                      return false;
                    }
                  }

                  // Date range filter
                  if (filterModel['dateRange'] != null) {
                    DateTimeRange dateRange = filterModel['dateRange'];
                    if (anniversary.date == null) {
                      return false;
                    }

                    // Extract month and day from anniversary date
                    int anniversaryMonth = anniversary.date!.month;
                    int anniversaryDay = anniversary.date!.day;

                    // Extract month and day from the start and end of the date range
                    int startMonth = dateRange.start.month;
                    int startDay = dateRange.start.day;
                    int endMonth = dateRange.end.month;
                    int endDay = dateRange.end.day;

                    // Check if the anniversary date falls within the date range, ignoring the year
                    if ((anniversaryMonth < startMonth ||
                            (anniversaryMonth == startMonth &&
                                anniversaryDay < startDay)) ||
                        (anniversaryMonth > endMonth ||
                            (anniversaryMonth == endMonth &&
                                anniversaryDay > endDay))) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                // Paginate the filtered data
                List<Anniversary> data = filteredData
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
            footer: DefaultFooter<String, Anniversary>(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width / 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              icons.first,
                              size: 22,
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              newTexts.first,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'HelveticaNeue',
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            anniversaries.length.toString(),
                            style: const TextStyle(
                              fontSize: 19,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Raleway',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            filters: [
              TextTableFilter(
                id: "content",
                chipFormatter: (value) {
                  return 'content has "$value"';
                },
                name: "Title",
                enabled: true,
              ),
              DateTimePickerTableFilter(
                initialDate: DateTime.now(),
                id: "date",
                name: "Date",
                chipFormatter: (value) {
                  return 'Anniversaries on "$value"';
                },
                enabled: true,
                dateFormat: DateFormat('dd/MM/yyyy'),
                initialValue: null,
                firstDate: DateTime(1880),
                lastDate: DateTime(DateTime.now().year + 1),
              ),
              DateRangePickerTableFilter(
                id: "dateRange",
                name: "Date Range",
                chipFormatter: (value) {
                  return 'Anniversaries from "${value?.start != null ? DateFormat('dd/MM/yyyy').format(value!.start) : 'N/A'} to ${value?.end != null ? DateFormat('dd/MM/yyyy').format(value!.end) : 'N/A'}"';
                },
                enabled: true,
                initialValue: null,
                firstDate: DateTime(DateTime.now().year),
                lastDate: DateTime(DateTime.now().year + 1),
                formatter: (dateRange) {
                  return 'Anniversaries from "${DateFormat('dd/MM/yyyy').format(dateRange.start)} to ${DateFormat('dd/MM/yyyy').format(dateRange.end)}"';
                },
              ),
              // TextTableFilter(
              //   id: "paperId",
              //   chipFormatter: (value) {
              //     return 'Id has "$value"';
              //   },
              //   name: "Paper Id",
              //   enabled: true,
              // ),
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
                         Navigator.push(context, MaterialPageRoute(builder: (_){
                          return const AddAnniversaryPage();
                         }));
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Refresh"),
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () async {
                              await anniversaryProvider.fetchAnniversaries();
                              setState(() {
                                tableController.refresh(fromStart: true);
                              });
                            },
                          );
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
              // RowSelectorColumn(),
              LargeTextTableColumn(
                title: const Text("Title"),
                id: "Title",
                size: const MaxColumnSize(
                    FractionalColumnSize(.25), FixedColumnSize(300)),
                getter: (item, index) => item.name ?? "N/A",
                fieldLabel: "Title",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.name = newValue;
                  return true;
                },
              ),

              LargeTextTableColumn(
                id: "upcomingDate",
                title: const Text("Upcoming Date"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.15), FixedColumnSize(100)),
                // size: const FractionalColumnSize(.2),
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
                title: const Text("Type"),
                id: "type",
                size: const MaxColumnSize(
                    FractionalColumnSize(.18), FixedColumnSize(120)),
                getter: (item, index) =>
                    item.anniversaryTypeId.description ?? "N/A",
                fieldLabel: "Anniversary Type",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.name = newValue;
                  return true;
                },
              ),

              // LargeTextTableColumn(
              //   title: const Text("Date Placed"),
              //   sortable: true,
              //   id: 'datePlaced',
              //   size: const MaxColumnSize(
              //       FractionalColumnSize(.12), FixedColumnSize(100)),
              //   // size: const FixedColumnSize(150),
              //   getter: (item, index) => item.date != null
              //       ? DateFormat('dd/MM/yyyy').format(item.date!)
              //       : 'N/A',
              //   setter: (item, newValue, index) async {
              //     await Future.delayed(const Duration(seconds: 2));
              //     item.date = newValue as DateTime?;
              //     return true;
              //   },
              //   fieldLabel: 'Date',
              // ),

              LargeTextTableColumn(
                sortable: true,
                id: "placedBy",
                title: const Text("Placed By"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.25), FixedColumnSize(300)),
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
                    operationsWidget(context, item.name ?? "N?A", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    print("friends" + item.friends!);
                    return AnniversaryDetailView(
                      anniversary: item,
                    );
                  }));
                }, () {
                  anniversaryProvider.deleteAnniversary(context, item.id!);
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {});
                  });
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
