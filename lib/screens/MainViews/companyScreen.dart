import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

import 'package:punch/admin/dialogs/add_company_dialog.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/constants/constants.dart';
import 'package:punch/models/myModels/companyModel.dart';

import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/providers/companyProvider.dart';

import 'package:punch/screens/EditViewPages/companyView.dart';
import 'package:punch/screens/ManageTypes/manageCompanySectors.dart';
import 'package:punch/widgets/operations.dart';
import 'package:punch/widgets/texts/richTextTableColumn.dart';

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
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<CompanyProvider>(context, listen: false)
    //       .tableController
    //       .removeFilters();
    // });
  }

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
    final tableController =
        Provider.of<CompanyProvider>(context, listen: false).tableController;
    final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;
    if (!_isInitialized) {
      return const Center(
        child: SpinKitWave(
          color: punchRed,
          size: 50.0,
        ),
      );
    }
    return PagedDataTableTheme(
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
      child:
          Consumer<CompanyProvider>(builder: (context, companyProvider, child) {
        final companies = companyProvider.companies;
        companies.sort((a, b) {
          String nameA = a.name?.isNotEmpty == true
              ? a.name!
              : '\uFFFF'; // Assign a high value to null/empty
          String nameB =
              b.name?.isNotEmpty == true ? b.name! : '\uFFFF'; // Same for b

          return nameA.compareTo(nameB);
        });

        if (companies.isEmpty) {
          return const Center(
            child: SpinKitWave(
              color: punchRed,
              size: 50.0,
            ),
          );
        }
        final pageSizes = calculatePageSizes(companies.length);
        return PagedDataTable<String, Company>(
          fixedColumnCount: 1,

          controller: tableController,

          configuration: const PagedDataTableConfiguration(),
          pageSizes: pageSizes,

          fetcher: (pageSize, sortModel, filterModel, pageToken) async {
            String? query = filterModel['content'] ??
                filterModel['address']?.toString() ??
                filterModel['date']?.toString() ??
                filterModel['companyNo']?.toString();
            try {
              int pageIndex = int.parse(pageToken ?? "0");

              // Filter data based on filterModel
              List<Company> filteredData = companies.where((company) {
                // Text filter
                if (filterModel['content'] != null &&
                    !company.name!
                        .toLowerCase()
                        .contains(filterModel['content'].toLowerCase())) {
                  return false;
                }
                if (filterModel['address'] != null &&
                    !company.address!
                        .toLowerCase()
                        .contains(filterModel['address'].toLowerCase())) {
                  return false;
                }

                if (filterModel['date'] != null) {
                  DateTime selectedDate = filterModel['date'];

                  if (company.date == null ||
                      DateTime(
                            company.date!.year,
                            company.date!.month,
                            company.date!.day,
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
                      company.companyNo == filterStaffNo) {
                    return true; // Include this user in the filtered results
                  } else {
                    return false; // Exclude users that do not match the filter
                  }
                }

                return true;
              }).toList();
              companyProvider.setQuery(query);
              // Paginate the filtered data
              List<Company> data = filteredData
                  .skip(pageSize * pageIndex)
                  .take(pageSize)
                  .toList();

              String? nextPageToken =
                  (data.length == pageSize) ? (pageIndex + 1).toString() : null;

              return (data, nextPageToken);
            } catch (e) {
              return Future.error('Error fetching page: $e');
            }
          },

          filters: [
            TextTableFilter(
              id: "content",
              chipFormatter: (value) {
                return 'Name has "$value"';
              },
              name: "Name",
              enabled: true,
            ),
            // DateTimePickerTableFilter(
            //   initialDate: DateTime.now(),
            //   id: "date",
            //   name: "Date",
            //   chipFormatter: (value) {
            //     return 'Anniversaries on "$value"';
            //   },
            //   enabled: true,
            //   dateFormat: DateFormat('dd/MM/yyyy'),
            //   initialValue: null,
            //   firstDate: DateTime(1880),
            //   lastDate: DateTime(DateTime.now().year + 1),
            // ),
            // TextTableFilter(
            //   id: "companyNo",
            //   chipFormatter: (value) {
            //     return 'Id has "$value"';
            //   },
            //   name: "Company No:",
            //   enabled: true,
            // ),
            // TextTableFilter(
            //   id: "address",
            //   chipFormatter: (value) {
            //     return 'Address has "$value"';
            //   },
            //   name: "Address",
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
                    if (!isUser)
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
                    if (!isUser)
                      PopupMenuItem(
                        child: const Text("Select Rows"),
                        onTap: () {
                          companyProvider.setBoolValue(true);
                        },
                      ),
                    if (!isUser)
                      PopupMenuItem(
                        child: const Text("Select all rows"),
                        onTap: () {
                          companyProvider.setBoolValue(true);
                          Future.delayed(Duration.zero, () {
                            tableController.selectAllRows();
                          });
                        },
                      ),
                    if (!isUser)
                      PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          companyProvider.setBoolValue(false);
                        },
                      ),
                    if (companyProvider.isRowsSelected && !isUser)
                      PopupMenuItem(
                        child: const Text("Delete Selected rows"),
                        onTap: () {
                          companyProvider.deleteSelectedCompanies(
                              context, tableController.selectedItems);
                          companyProvider.setBoolValue(true);
                        },
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

          footer: DefaultFooter<String, Company>(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: !Responsive.isMobile(context)
                  ? Container(
                      width: Responsive.isTablet(context)
                          ? MediaQuery.of(context).size.width / 12
                          : MediaQuery.of(context).size.width / 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  icons[2],
                                  size: 22,
                                  color: secondaryColor,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                companies.length.toString(),
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
                    )
                  : const SizedBox(),
            ),
          ),

          columns: [
            if (companyProvider.isRowsSelected) RowSelectorColumn(),
           
            HighlightQueryColumn(
                 fieldLabel: "Company Name",
              title: const Text("Name"),
              id: "Title",
              size: const FixedColumnSize(300),
              query: companyProvider.query?.toLowerCase() ??
                  "", // Replace with your search query
              getter: (item, index) => item.name ?? "N/A",
              setter: (item, newValue, index) async {
                return false;
              },
            ),
            LargeTextTableColumn(
              title: const Text("Date "),
              sortable: true,
              id: 'date',
              size: FixedColumnSize(150),
              // size: const FixedColumnSize(150),
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
              title: const Text("Company No:"),
              id: "CompanyNo",
              size: FixedColumnSize(150),
              getter: (item, index) {
                if (item.companyNo == null) {
                  return 'N/A'; // Handle null value for company name
                }
                return item.companyNo.toString();
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
              size: FixedColumnSize(300),
              getter: (item, index) {
                if (item.address == null) {
                  return 'N/A'; // Handle null value for company name
                }
                return item.address!;
              },
              fieldLabel: "Address",
              setter: (item, newValue, index) async {
                await Future.delayed(const Duration(seconds: 2));
                item.address = newValue;
                return true;
              },
            ),

            TableColumn(
              title: const Text("Operations"),
              size: const FixedColumnSize(160),
              cellBuilder: (context, item, index) =>
                  operationsWidget(context, item.name ?? "N/A", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return CompanyDetailView(
                    company: item,
                  );
                }));
              }, () {
                companyProvider.deleteCompany(context, item);
              }),
            ),
          ],
        );
      }),
    );
  }
}
