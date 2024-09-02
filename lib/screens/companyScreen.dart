import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

import 'package:punch/admin/dialogs/add_company_dialog.dart';

import 'package:punch/models/myModels/companyWithExtra.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/providers/companyProvider.dart';

import 'package:punch/screens/companyView.dart';
import 'package:punch/screens/manageCompanySectors.dart';
import 'package:punch/widgets/operations.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
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

  final tableController = PagedDataTableController<String, CompanyWithExtra>();
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
         final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;
    if (!_isInitialized ||
        Provider.of<CompanyProvider>(context).loadingMerged) {
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
        child: Consumer<CompanyProvider>(
            builder: (context, companyProvider, child) {
          final companies = companyProvider.mergedCompanyWithExtras;
          // companies.sort((a, b) {
          //   if (a.company.date! == null && b.company.date == null)
          //     return 0; // Both dates are null
          //   if (a.company.date == null) return 1; // a is null, place a after b
          //   if (b.company.date == null) return -1; // b is null, place b after a
          //   return a.company.date!.compareTo(
          //       b.company.date!); // Both dates are not null, compare normally
          // });

          if (companies.isEmpty) {
            return const Center(
              child: SpinKitWave(
                color: punchRed,
                size: 50.0,
              ),
            );
          }
          final pageSizes = calculatePageSizes(companies.length);
          return PagedDataTable<String, CompanyWithExtra>(
            fixedColumnCount: 1,

            controller: tableController,

            configuration: const PagedDataTableConfiguration(),
            pageSizes: pageSizes,

            fetcher: (pageSize, sortModel, filterModel, pageToken) async {
              try {
                int pageIndex = int.parse(pageToken ?? "0");

                // Filter data based on filterModel
                List<CompanyWithExtra> filteredData =
                    companies.where((company) {
                  // Text filter
                  if (filterModel['content'] != null &&
                      !company.company.name!
                          .toLowerCase()
                          .contains(filterModel['content'].toLowerCase())) {
                    return false;
                  }
                  if (filterModel['address'] != null &&
                      !company.company.address!
                          .toLowerCase()
                          .contains(filterModel['address'].toLowerCase())) {
                    return false;
                  }

                  if (filterModel['date'] != null) {
                    DateTime selectedDate = filterModel['date'];

                    if (company.company.date == null ||
                        DateTime(
                              company.company.date!.year,
                              company.company.date!.month,
                              company.company.date!.day,
                            ).compareTo(DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                            )) !=
                            0) {
                      return false;
                    }
                  }

                  if (filterModel['companyNo'] != null) {
                    String filterInput = filterModel['companyNo'].trim();
                    int? filterStaffNo = int.tryParse(filterInput);

                    if (filterStaffNo != null &&
                        company.company.companyNo == filterStaffNo) {
                      return true; // Include this user in the filtered results
                    } else {
                      return false; // Exclude users that do not match the filter
                    }
                  }

                  return true;
                }).toList();

                // Paginate the filtered data
                List<CompanyWithExtra> data = filteredData
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
              TextTableFilter(
                id: "companyNo",
                chipFormatter: (value) {
                  return 'Id has "$value"';
                },
                name: "Company No:",
                enabled: true,
              ),
              TextTableFilter(
                id: "address",
                chipFormatter: (value) {
                  return 'Address has "$value"';
                },
                name: "Address",
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
                      if(!isUser)
                      PopupMenuItem(
                        child: const Text("Add Company"),
                        onTap: () {
                          // WidgetsBinding.instance.addPostFrameCallback((_) {
                          //   showAddAnniversaryDialog(context);
                          // });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return AddCompanyPage();
                          }));
                        },
                      ),
          if (!isUser)
                         PopupMenuItem(
                        child: const Text("Edit Company Sectors"),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return ManageCompanySectorsPage();
                          }));
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Refresh"),
                        onTap: () {
                          companyProvider.fetchCompanies();
                          tableController.refresh();
                        },
                      ),
                     if (!isUser)    PopupMenuItem(
                        child: const Text("Select Rows"),
                        onTap: () {
                          companyProvider.setBoolValue(true);
                        },
                      ),
                     if (!isUser)    PopupMenuItem(
                        child: const Text("Select all rows"),
                        onTap: () {
                          companyProvider.setBoolValue(true);
                          Future.delayed(Duration.zero, () {
                            tableController.selectAllRows();
                          });
                        },
                      ),
                     if (!isUser)    PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          companyProvider.setBoolValue(false);
                        },
                      ),
                      if (companyProvider.isRowsSelected && !isUser)
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
              if (companyProvider.isRowsSelected) RowSelectorColumn(),
              // RowSelectorColumn(),
              LargeTextTableColumn(
                title: const Text("Title"),
                id: "Title",
                size: const MaxColumnSize(
                    FractionalColumnSize(.3), FixedColumnSize(300)),
                getter: (item, index) {
                  if (item.company.name == null) {
                    return 'N/A'; // Handle null value for company name
                  }
                  return item.company.name!;
                },
                fieldLabel: "Title",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.company.name = newValue;
                  return true;
                },
              ),

              LargeTextTableColumn(
                title: const Text("Date "),
                sortable: true,
                id: 'date',
                size: const MaxColumnSize(
                    FractionalColumnSize(.12), FixedColumnSize(150)),
                // size: const FixedColumnSize(150),
                getter: (item, index) => item.company.date != null
                    ? DateFormat('dd/MM/yyyy').format(item.company.date!)
                    : 'N/A',
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.company.date = newValue as DateTime?;
                  return true;
                },
                fieldLabel: 'Date',
              ),
              LargeTextTableColumn(
                title: const Text("Company No:"),
                id: "CompanyNo",
                size: const MaxColumnSize(
                    FractionalColumnSize(.15), FixedColumnSize(150)),
                getter: (item, index) {
                  if (item.company.companyNo == null) {
                    return 'N/A'; // Handle null value for company name
                  }
                  return item.company.companyNo.toString();
                },
                fieldLabel: "Company No",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  //   item.companyNo = newValue;
                  return true;
                },
              ),
              LargeTextTableColumn(
                sortable: true,
                id: "address",
                title: const Text("Address"),
                size: const MaxColumnSize(
                    FractionalColumnSize(.25), FixedColumnSize(300)),
                getter: (item, index) {
                  if (item.company.address == null) {
                    return 'N/A'; // Handle null value for company name
                  }
                  return item.company.address!;
                },
                fieldLabel: "Address",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.company.address = newValue;
                  return true;
                },
              ),

              TableColumn(
                title: const Text("Operations"),
                size: const RemainingColumnSize(),
                cellBuilder: (context, item, index) =>
                    operationsWidget(context, item.company.name ?? "N/A", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return CompanyDetailView(
                      company: item,
                    );
                  }));
                }, () {
                  //anniversaryProvider.deleteAnniversary(context, item.id!);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
