import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/dialogs/add_client_page.dart';
import 'package:punch/admin/responsive.dart';

import 'package:punch/constants/constants.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/providers/clientProvider.dart';

import 'package:punch/screens/clientDetailView.dart';
import 'package:punch/screens/manageClientTitlePage.dart';

import 'package:punch/widgets/operations.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {

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
   
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<ClientProvider>(context, listen: false)
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
        Provider.of<ClientProvider>(context, listen: false).tableController;
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
    return SafeArea(
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
        child:
            Consumer<ClientProvider>(builder: (context, clientProvider, child) {
          final clients = clientProvider.clients;
       clients.sort((a, b) {
            String nameA = a.firstName?.isNotEmpty == true
                ? a.firstName!
                : '\uFFFF'; // Handle null/empty firstName for a
            String nameB = b.firstName?.isNotEmpty == true
                ? b.firstName!
                : '\uFFFF'; // Handle null/empty firstName for b
            
            return nameA.compareTo(nameB);
          });
            
            
          if (clients.isEmpty) {
            return const Center(
              child: SpinKitWave(
                color: punchRed,
                size: 50.0,
              ),
            );
          }
          final pageSizes = calculatePageSizes(clients.length);
          return PagedDataTable<String, Client>(
             fetcher: (pageSize, sortModel, filterModel, pageToken) {
              try {
                int pageIndex = int.parse(pageToken ?? "0");
            
                // Filter data based on filterModel
                List<Client> filteredData = clients.where((client) {
                  // Text filter
                  if (filterModel['firstName'] != null &&
                      !client.firstName!
                          .toLowerCase()
                          .contains(filterModel['firstName'].toLowerCase())) {
                    return false;
                  }
            
                  if (filterModel['clientNo'] != null) {
                    String filterInput = filterModel['clientNo'].trim();
                    int? filterStaffNo = int.tryParse(filterInput);
            
                    if (filterStaffNo != null &&
                        client.clientNo == filterStaffNo) {
                      return true; // Include this user in the filtered results
                    } else {
                      return false; // Exclude users that do not match the filter
                    }
                  }
            
                  if (filterModel['email'] != null &&
                      !client.email!
                          .toLowerCase()
                          .contains(filterModel['email'].toLowerCase())) {
                    return false;
                  }
            
                  return true;
                }).toList();
            
                // Paginate the filtered data
                List<Client> data = filteredData
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
            fixedColumnCount: 1,
            
            controller: tableController,
            
            configuration: const PagedDataTableConfiguration(),
            pageSizes: pageSizes,
            
           
            
            filters: [
              TextTableFilter(
                id: "firstName",
                chipFormatter: (value) {
                  return 'firstName has "$value"';
                },
                name: "First Name",
                enabled: true,
              ),
              TextTableFilter(
                id: "clientNo",
                chipFormatter: (value) {
                  return 'Client No has "$value"';
                },
                name: "Client No:",
                enabled: true,
              ),
              TextTableFilter(
                id: "email",
                chipFormatter: (value) {
                  return 'Email has "$value"';
                },
                name: "Email",
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
                        child: const Text("Add Client"),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return AddClientPage();
                          }));
                        },
                      ),
                        if (!isUser)
                      PopupMenuItem(
                        child: const Text("Edit client title"),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return ManageClientTitlePage();
                          }));
                        },
                      ),
                      PopupMenuItem(
                        child: const Text("Refresh"),
                        onTap: () {
                          clientProvider.fetchClients();
                          tableController.refresh();
                        },
                      ),
                    if (!isUser)    PopupMenuItem(
                        child: const Text("Select Rows"),
                        onTap: () {
                          clientProvider.setBoolValue(true);
                        },
                      ),
                      if (!isUser)  PopupMenuItem(
                        child: const Text("Select all rows"),
                        onTap: () {
                          clientProvider.setBoolValue(true);
                          Future.delayed(Duration.zero, () {
                            tableController.selectAllRows();
                          });
                        },
                      ),
                      if (!isUser)  PopupMenuItem(
                        child: const Text("Unselect all rows"),
                        onTap: () {
                          tableController.unselectAllRows();
                          clientProvider.setBoolValue(false);
                        },
                      ),
                      if (clientProvider.isRowsSelected && !isUser)
                        PopupMenuItem(
                          child: const Text("Delete Selected rows"),
                          onTap: () async{
                      await      clientProvider.deleteSelectedClients(
                                context, tableController.selectedItems);
                                   clientProvider.setBoolValue(false);
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
            
            footer: DefaultFooter<String, Client>(
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
                                    icons[1],
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
                                  clients.length.toString(),
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
              if (clientProvider.isRowsSelected) RowSelectorColumn(),
              // RowSelectorColumn(),
              LargeTextTableColumn(
                title: const Text("First Name"),
                id: "firstName",
                // size: const MaxColumnSize(
                //     FractionalColumnSize(.3), FixedColumnSize(300)),
                size: const FixedColumnSize(210),
                getter: (item, index) => item.firstName ?? "N/A",
                fieldLabel: "firstName",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.firstName = newValue;
                  return true;
                },
              ),
              LargeTextTableColumn(
                title: const Text("Middle Name"),
                id: "middleName",
                // size: const MaxColumnSize(
                //     FractionalColumnSize(.3), FixedColumnSize(300)),
                size: const FixedColumnSize(200),
                getter: (item, index) => item.middleName ?? "N/A",
                fieldLabel: "middleName",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.middleName = newValue;
                  return true;
                },
              ),
            
              LargeTextTableColumn(
                title: const Text("Date of Birth "),
                sortable: true,
                id: 'date',
                // size: const MaxColumnSize(
                //     FractionalColumnSize(.12), FixedColumnSize(150)),
                size: const FixedColumnSize(150),
                getter: (item, index) => item.dateOfBirth != null
                    ? DateFormat('dd/MM/yyyy').format(item.dateOfBirth!)
                    : 'N/A',
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.dateOfBirth = newValue as DateTime?;
                  return true;
                },
                fieldLabel: 'Date',
              ),
              LargeTextTableColumn(
                title: const Text("Client No:"),
                id: "clientNo",
                size: const FixedColumnSize(150),
                // size: const MaxColumnSize(
                //     FractionalColumnSize(.15), FixedColumnSize(150)),
                getter: (item, index) => item.clientNo.toString(),
                fieldLabel: "Title",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  //   item.companyNo = newValue;
                  return true;
                },
              ),
              LargeTextTableColumn(
                sortable: true,
                id: "email",
                title: const Text("Email"),
                // size: const MaxColumnSize(
                //     FractionalColumnSize(.25), FixedColumnSize(300)),
                size: const FixedColumnSize(250),
                getter: (item, index) => item.email,
                fieldLabel: "Email",
                setter: (item, newValue, index) async {
                  await Future.delayed(const Duration(seconds: 2));
                  item.email = newValue;
                  return true;
                },
              ),
            
              TableColumn(
                title: const Text("Operations"),
                // size: const RemainingColumnSize(),
                size: const FixedColumnSize(160),
                cellBuilder: (context, item, index) =>
                    operationsWidget(context, item.firstName ?? "N?A", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ClientDetailView(
                      client: item,
                    );
                  }));
                }, () async {
                  clientProvider.deleteClient(context, item);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
