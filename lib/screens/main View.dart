import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/dialogs/add_anniversary_dialog.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/constants/constants.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/screens/anniversaryView.dart';
import 'package:punch/screens/manageAnniversaryTypes.dart';
import 'package:punch/screens/managepapersPage.dart';

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
    if(mounted){
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

    final isUser = auth.user?.loginId == UserRole.user;

    final tableController =
        Provider.of<AnniversaryProvider>(context, listen: false)
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
       // footerTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
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
                    
                    child:!Responsive.isMobile(context) ?  Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            width:  Responsive.isTablet(context)
                      ? MediaQuery.of(context).size.width / 12: MediaQuery.of(context).size.width / 15,
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
                      anniversaries.length.toString(),
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
          )
                    ): const SizedBox(),
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
          ],
          filterBarChild: IconTheme(
            data: const IconThemeData(color: Colors.black),
            child: PopupMenuButton(
                clipBehavior: Clip.hardEdge,
                icon: const Icon(Icons.more_vert_outlined),
                itemBuilder: (context) {
                  return <PopupMenuEntry>[
                  if(!isUser)  PopupMenuItem(
                      child: const Text("Add anniversary"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                          return const AddAnniversaryPage();
                        }));
                      },
                    ),
                    if (!isUser)    PopupMenuItem(
                      child: const Text("Edit anniversary types"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                          return  ManageAnniversaryTypesPage();
                        }));
                      },
                    ),
                  if (!isUser)      PopupMenuItem(
                      child: const Text("Edit Papers"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                          return  ManagePapersPage();
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
                       if (!isUser) PopupMenuItem(
                      child: const Text("Select Rows"),
                      onTap: () {
                        anniversaryProvider.setBoolValue(true);
                      },
                    ),
                    if (!isUser)    PopupMenuItem(
                      child: const Text("Select all rows"),
                      onTap: () {
                        anniversaryProvider.setBoolValue(true);
                        Future.delayed(Duration.zero, () {
                          tableController.selectAllRows();
                        });
                      },
                    ),
                    if (anniversaryProvider.isRowsSelected && !isUser)
                      PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          anniversaryProvider.setBoolValue(false);
                        },
                      ),
                    if (anniversaryProvider.isRowsSelected && !isUser)
                      PopupMenuItem(
                        child: const Text("Delete Selected rows"),
                        onTap: () async {
                          await  anniversaryProvider.deleteSelectedAnniversaries(
                              context, tableController.selectedItems);
                       anniversaryProvider.setBoolValue(false);
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
            if (anniversaryProvider.isRowsSelected) RowSelectorColumn(),
           
            LargeTextTableColumn(
              title: const Text("Title"),
              id: "Title",
              size: const FixedColumnSize(320),
              getter: (item, index) => item.name ?? "N/A",
              fieldLabel: "Title",
              setter: (item, newValue, index) async {
                return false;
              },
            ),
        
            TableColumn(
              id: "upcomingDate",
              title: const Text("Upcoming Date"),
              // size: const MaxColumnSize(
              //     FractionalColumnSize(.15), FixedColumnSize(100)),
              size: const FixedColumnSize(150),
              cellBuilder: (context, item, index) {
                if (item.date == null) {
                  return const Text('N/A');
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
                  return const Text("Today");
                } else if (difference.inDays == 1) {
                  return const Text("Tomorrow");
                } else if (difference.inDays < 7) {
                  return Text(DateFormat('EEEE')
                      .format(nextAnniversary)); // Day of the week
                } else {
                  return Text(DateFormat('dd/MM/yyyy')
                      .format(nextAnniversary)); // Full date
                }
              },
            ),
        
        DropdownTableColumn(

              sortable: true,
              id: "type",
              title: const Text("Type"),
              items: [
                // Add a default or "Select Type" option if desired
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    "Select Type", // Default or fallback option
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                ...anniversaryProvider.anniversaryTypes.entries.map((entry) {
                  return DropdownMenuItem<int?>(
                    value:
                        entry.key, // Use the Anniversary_Type_Id as the value
                    child: Text(
                      entry.value, // Use the description as the display text
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ],
              size: const FixedColumnSize(210),
              getter: (item, index) {
              
                int? typeId = item.anniversaryTypeId;
                if (typeId == null ||
                    !anniversaryProvider.anniversaryTypes
                        .containsKey(typeId)) {
                  return null; // or return a default/fallback typeId if necessary
                }
                return typeId;
              },
              setter: (item, newValue, index) async {
               
                return false; // Return false if no new type was selected or if the type is the same
              },
            ),
    
            LargeTextTableColumn(
              sortable: true,
              id: "placedBy",
              title: const Text("Placed By"),
              size:const FixedColumnSize(320),
              getter: (item, index) {
                if (item.placedByName == null || item.placedByName == "") {
                  return "N/A";
                }
        
                return item.placedByName;
              },
              fieldLabel: "Placed By",
              setter: (item, newValue, index) async {
             
                return false;
              },
            ),
        
            TableColumn(
              title: const Text("Operations"),
           
              size: const FixedColumnSize(160),
              cellBuilder: (context, item, index) =>
                  operationsWidget(context, item.name ?? "N?A", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  print("friends" + item.friends!);
                  return AnniversaryDetailView(
                    anniversary: item,
                  );
                }));
              }, () {
                anniversaryProvider.deleteAnniversary(context, item);
               
            
              }),
            ),
          ],
        );
      }),
    );
  }
}
