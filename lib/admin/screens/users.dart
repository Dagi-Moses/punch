import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/dialogs/add_anniversary_dialog.dart';

import 'package:punch/models/myModels/userWithRecord.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/widgets/operations.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
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

  final tableController = PagedDataTableController<String, UserWithRecord>();
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
          borderRadius: BorderRadius.circular(10),
          filterBarHeight: 35,
          backgroundColor: Colors.white,
          cellTextStyle: const TextStyle(color: Colors.black),
          elevation: 10,
          headerTextStyle: const TextStyle(color: Colors.black),
          footerTextStyle: const TextStyle(color: Colors.black),
        ),
        child: Consumer<AuthProvider>(builder: (context, authProvider, child) {
          final users = authProvider.mergedUsersWithRecords;
          final pageSizes = calculatePageSizes(users.length);
          return PagedDataTable<String, UserWithRecord>(
            fixedColumnCount: 1,
            // initialPageSize: 1,
            controller: tableController,
            configuration: const PagedDataTableConfiguration(),
            // pageSizes: pageSizes.isEmpty ? null : pageSizes,
            fetcher: (pageSize, sortModel, filterModel, pageToken) async {
              try {
                int pageIndex = int.parse(pageToken ?? "0");
                // Filter data based on filterModel
                List<UserWithRecord> filteredData = users.where((anniversary) {
                  // Text filter
                  if (filterModel['content'] != null &&
                      !anniversary.userModel.username!
                          .toLowerCase()
                          .contains(filterModel['content'].toLowerCase())) {
                    return false;
                  }
                  // if (filterModel['date'] != null) {
                  //   DateTime selectedDate = filterModel['date'];

                  //   if (anniversary.date == null ||
                  //       DateTime(
                  //             // anniversary.date!.year,
                  //             anniversary.date!.month,
                  //             anniversary.date!.day,
                  //           ).compareTo(DateTime(
                  //             // selectedDate.year,
                  //             selectedDate.month,
                  //             selectedDate.day,
                  //           )) !=
                  //           0) {
                  //     return false;
                  //   }
                  // }

                  // Date range filter
                  // if (filterModel['dateRange'] != null) {
                  //   DateTimeRange dateRange = filterModel['dateRange'];
                  //   if (anniversary.date == null ||
                  //       anniversary.date!.isBefore(dateRange.start) ||
                  //       anniversary.date!.isAfter(dateRange.end)) {
                  //     return false;
                  //   }
                  // }
                  // if (filterModel['paperID'] != null &&
                  //     !anniversary.paperId!
                  //         .toString()
                  //         .contains(filterModel['paperId'].toLowerCase())) {
                  //   return false;
                  // }

                  return true;
                }).toList();

                // Paginate the filtered data
                List<UserWithRecord> data = filteredData
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
                chipFormatter: (value) {
                  return 'content has "$value"';
                },
                name: "Username",
                enabled: true,
              ),
              DateTimePickerTableFilter(
                initialDate: DateTime.now(),
                id: "date",
                name: "Upcoming Date",
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
                firstDate: DateTime(1880),
                lastDate: DateTime(DateTime.now().year + 1),
                formatter: (dateRange) {
                  return 'Anniversaries from "${DateFormat('dd/MM/yyyy').format(dateRange.start)} to ${DateFormat('dd/MM/yyyy').format(dateRange.end)}"';
                },
              ),
              TextTableFilter(
                id: "paperId",
                chipFormatter: (value) {
                  return 'Id has "$value"';
                },
                name: "Paper Id",
                enabled: true,
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
                        child: const Text("Add Test anniversary"),
                        onTap: () {
                          authProvider.addTestUser();
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Refresh"),
                        onTap: () {
                          // anniversaryProvider.fetchAnniversaries();
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Select Rows"),
                        onTap: () {
                          // anniversaryProvider.setBoolValue(true);
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Select all rows"),
                        onTap: () {
                          //   anniversaryProvider.setBoolValue(true);
                          Future.delayed(Duration.zero, () {
                            tableController.selectAllRows();
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          // anniversaryProvider.setBoolValue(false);
                        },
                      ),
                      // if (anniversaryProvider.isRowsSelected)
                      //   PopupMenuItem(
                      //     child: const Text("Delete Selected rows"),
                      //     onTap: () {},
                      //   ),
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
              if (authProvider.isRowsSelected) RowSelectorColumn(),
              LargeTextTableColumn(
                title: const Text("Username"),
                id: "username",
                size: const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(250)),
                getter: (item, index) => item.userModel.username ?? "N/A",
                fieldLabel: "username",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.userModel.username = newValue;
                  return true;
                },
              ),
              LargeTextTableColumn(
                sortable: true,
                id: "staffNo",
                title: const Text("Staff No"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(250)),
                getter: (item, index) => item.userModel.staffNo.toString(),
                fieldLabel: "Staff No",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.userRecordModel.staffNo = newValue as int?;
                  return true;
                },
              ),
              LargeTextTableColumn(
                title: const Text("Login Date Time"),
                sortable: true,
                id: 'loginDateTime',
                size:  const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(250)),
                // size: const FixedColumnSize(150),
                getter: (item, index) =>
                    item.userRecordModel.loginDateTime != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(item.userRecordModel.loginDateTime!)
                        : 'N/A',
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.userRecordModel.loginDateTime = newValue as DateTime?;
                  return true;
                },
                fieldLabel: 'Date Time',
              ),
              LargeTextTableColumn(
                title: const Text("Login System info"),
                sortable: true,
                id: 'loginSystemInfo',
                size: const MaxColumnSize(
                    FractionalColumnSize(.2), FixedColumnSize(250)),
                // size: const FixedColumnSize(150),
                getter: (item, index) =>
                    item.userRecordModel.computerName ?? "N/A",

                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.userRecordModel.computerName = newValue;
                  return true;
                },
                fieldLabel: 'Login system info',
              ),
              TableColumn(
                title: const Text("Operations"),
                size: const RemainingColumnSize(),
                cellBuilder: (context, item, index) => operationsWidget(
                    context, item.userModel.username ?? "N?A", () {}, () {
                  // anniversaryProvider.deleteAnniversary(context, item.id!);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
