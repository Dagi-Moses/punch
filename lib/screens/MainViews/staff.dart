import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/constants/constants.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/models/myModels/staff.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/sexProvider.dart';
import 'package:punch/providers/staffprovider.dart';
import 'package:punch/providers/titleProvider.dart';

import 'package:punch/widgets/operations.dart';
import 'package:punch/widgets/texts/richTextTableColumn.dart';

class StaffView extends StatefulWidget {
  const StaffView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {


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
    final auth = Provider.of<AuthProvider>(context);
    final titles = Provider.of<TitleProvider>(context);
    final sexes = Provider.of<SexProvider>(context);
    final isUser = auth.user?.loginId == UserRole.user;
    final screenSize = MediaQuery.of(context).size.width;
    final tableController =
        Provider.of<StaffProvider>(context, listen: false)
            .tableController;
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
        cellPadding: const EdgeInsets.all(0),
        horizontalScrollbarVisibility: true,
        verticalScrollbarVisibility: true,
        borderRadius: BorderRadius.circular(10),
        filterBarHeight: 35,
        backgroundColor: Colors.white,
        cellTextStyle: const TextStyle(
          color: Colors.black,
        ),
        elevation: 10,
        headerTextStyle: const TextStyle(color: Colors.black),
      
      ),
      child: Consumer<StaffProvider>(
          builder: (context, staffProvider, child) {
        List<Staff> staffs = staffProvider.staffs;
       
        staffs.sort((a, b) {
          String nameA = a.lastName?.isNotEmpty == true
              ? a.lastName!
              : '\uFFFF'; 
          String nameB = b.lastName?.isNotEmpty == true
              ? b.lastName!
              : '\uFFFF'; 

          return nameA.compareTo(nameB);
        });

        if (staffs.isEmpty) {
          return const Center(
            child: SpinKitWave(
              color: punchRed,
              size: 50.0,
            ),
          );
        }
        final pageSizes = calculatePageSizes(staffs.length);
        return PagedDataTable<String, Staff>(
          fixedColumnCount: 1,
          controller: tableController,
          configuration: const PagedDataTableConfiguration(),
          pageSizes: pageSizes,
          initialPageSize: staffs.length,
          fetcher: (pageSize, sortModel, filterModel, pageToken) {
            try {
              int pageIndex = int.parse(pageToken ?? "0");

              List<Staff> filteredData = staffs.where((staff) {
            
                String? query = filterModel['Name'];
                staffProvider.setQuery(query);
          
                if (query == null || query.isEmpty) {
                  return true;
                }
                query = query.toLowerCase();
                bool matchesFirstName = staff.firstName != null &&
                    staff.firstName!.toLowerCase().startsWith(query);
                bool matchesMiddleName = staff.middleName != null &&
                    staff.middleName!.toLowerCase().startsWith(query);
                bool matchesLastName = staff.lastName != null &&
                    staff.lastName!.toLowerCase().startsWith(query);
                return matchesFirstName || matchesMiddleName || matchesLastName;
              }).toList();

              // Paginate the filtered data
              List<Staff> data = filteredData
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
          footer: DefaultFooter<String, Staff>(
            child: !Responsive.isMobile(context)
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
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
                                  icons.first,
                                  size: 20,
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
                                staffs.length.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Raleway',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                : const SizedBox(),
          ),
        filters: [
            TextTableFilter(
              id: "Name",
              chipFormatter: (value) {
                return 'Staff Name Starts With "$value"';
              },
              name: "Name",
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
                    // if (!isUser)
                    //   PopupMenuItem(
                    //     child: const Text("Add Staff"),
                    //     onTap: () {
                    //       Navigator.push(context,
                    //           MaterialPageRoute(builder: (_) {
                    //         return const AddAnniversaryPage();
                    //       }));
                    //     },
                    //   ),
                
                    PopupMenuItem(
                      child: const Text("Refresh"),
                      onTap: () {
                        Future.delayed(
                          Duration.zero,
                          () async {
                            await staffProvider.fetchStaffs();
                            setState(() {
                              tableController.refresh(fromStart: true);
                            });
                          },
                        );
                      },
                    ),
                    if (!isUser)
                      PopupMenuItem(
                        child: const Text("Select Rows"),
                        onTap: () {
                          staffProvider.setBoolValue(true);
                        },
                      ),
                    if (!isUser)
                      PopupMenuItem(
                        child: const Text("Select all rows"),
                        onTap: () {
                          staffProvider.setBoolValue(true);
                          Future.delayed(Duration.zero, () {
                            tableController.selectAllRows();
                          });
                        },
                      ),
                    if (staffProvider.isRowsSelected && !isUser)
                      PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          staffProvider.setBoolValue(false);
                        },
                      ),
                    if (staffProvider.isRowsSelected && !isUser)
                      PopupMenuItem(
                        child: const Text("Delete Selected rows"),
                        onTap: () async {
                          await staffProvider.deleteSelectedStaffs(
                              context, tableController.selectedItems);
                          staffProvider.setBoolValue(false);
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
          columns: [
            if (staffProvider.isRowsSelected) RowSelectorColumn(),
            HighlightQueryColumn(
              fieldLabel: "lastName",
              title: const Text("Last Name"),

              id: "lastName",
              size: const FixedColumnSize(200),
              query: staffProvider.query?.toLowerCase() ??
                  "",
              getter: (item, index) => item.lastName ?? "N/A",
              setter: (item, newValue, index) async {
                await Future.delayed(const Duration(seconds: 2));
                item.lastName = newValue;
                return true;
              },
            ),
            HighlightQueryColumn(
              fieldLabel: "middleName",
              title: const Text("Middle Name"),

              id: "middleName",
              size: const FixedColumnSize(200),
              query: staffProvider.query?.toLowerCase() ??
                  "", 
              getter: (item, index) => item.middleName ?? "N/A",
              setter: (item, newValue, index) async {
                await Future.delayed(const Duration(seconds: 2));
                item.middleName = newValue;
                return true;
              },
            ),
            HighlightQueryColumn(
              fieldLabel: "firstName",
              title: const Text("First Name"),
              id: "firstName",
              size: const FixedColumnSize(200),
              query: staffProvider.query?.toLowerCase() ??
                  "", 
              getter: (item, index) => item.firstName ?? "N/A",
              setter: (item, newValue, index) async {
                await Future.delayed(const Duration(seconds: 2));
                item.firstName = newValue;
                return true;
              },
            ),
              LargeTextTableColumn(
              sortable: true,
              id: "title",
              title: const Text("Title"),
              size: const FixedColumnSize(150),
             
               getter: (item, index) {
                int? typeId = item.title;
                if (typeId == null ||
                    !titles.titles.containsKey(typeId)) {
                  return "Unknown"; // Return fallback text if typeId is null or not found
                }
                return titles
                    .titles[typeId]!; // Fetch the description
              },
              fieldLabel: "Titles",
              setter: (item, newValue, index) async {
                await Future.delayed(const Duration(seconds: 2));

                return true;
              },
            ),
           
            LargeTextTableColumn(
              title: const Text("Gender"),
              id: "gender",
              size: const FixedColumnSize(150),
             
              getter: (item, index) {
                String? sexCode = item.sex;
                if (sexCode == null || !sexes.sexes.containsKey(sexCode)) {
                  return "Unknown"; // Return fallback text if typeId is null or not found
                }
                return sexes.sexes[sexCode]!; // Fetch the description
              },
              fieldLabel: "Gender",
              setter: (item, newValue, index) async {
                await Future.delayed(const Duration(seconds: 2));
             
                return true;
              },
            ),
            TableColumn(
              title: const Text("Operations"),
              size: const FixedColumnSize(160),
              cellBuilder: (context, item, index) =>
                  operationsWidget(context, item.firstName ?? "N?A", () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) {
                //   return ClientDetailView(
                //     client: item,
                //   );
                // }));
              }, () async {
                staffProvider.deleteStaff(context, item);
              }),
            ),
          ],
        );
      }),
    );
  }
}
