import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/anniversary/oldAnniversaryModel.dart';
import 'package:punch/models/myModels/anniversary/anniversarySector.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:punch/models/myModels/staff.dart';
import 'package:punch/src/const.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:paged_datatable/paged_datatable.dart';

class StaffProvider with ChangeNotifier {
  late WebSocketChannel channel;

  List<Staff> _staffs = [];
  List<Staff> get staffs => _staffs;

  String? _query;
  String? get query => _query;

  void setQuery(String? newQuery) {
    if (_query != newQuery) {
      _query = newQuery;
      notifyListeners();
    }
  }



  List<AnniversarySector> _anniversarySectors = [];
  List<AnniversarySector> get anniversarySectors => _anniversarySectors;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  int? _anniversaryYear;
  int? get anniversaryYear => _anniversaryYear;

  bool _isAnniversaryYearEnabled = false;
  bool get isAnniversaryYearEnabled => _isAnniversaryYearEnabled;

  bool _loading = false;
  bool get loading => _loading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  bool _updateLoading = false;
  bool get updateloading => _updateLoading;

  bool _isRowsSelected = false;
  bool get isRowsSelected => _isRowsSelected;

  DateTime? _selectedDetailsDate;
  DateTime? get selectedDetailsDate => _selectedDetailsDate;

  set selectedDetailsDate(DateTime? date) {
    _selectedDetailsDate = date;
    notifyListeners(); 
  }

  int? _selectedType;
  int? get selectedType => _selectedType;



  // set selectedType(int? newValue) {
  //   _selectedType = newValue;
  //   notifyListeners();
  // }

  set isEditing(bool newValue) {
    _isEditing = newValue;
    notifyListeners();
  }

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  late WebSocketManager _webSocketManager;
  final tableController = PagedDataTableController<String, Staff>();

  StaffProvider() {
    channel = WebSocketChannel.connect(Uri.parse(Const.staffChannel));
    fetchStaffs();
    _initializeWebSocket();
   
  }

  void _initializeWebSocket() {
    _webSocketManager = WebSocketManager(
      Const.staffChannel,
      _handleWebSocketMessage,
      _reconnectWebSocket,
    );
    _webSocketManager.connect();
  }

  void _reconnectWebSocket() {
    print("reconnected");
  }

  void _handleWebSocketMessage(dynamic message) async {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        // Directly add the new anniversary to the list
        final newStaff = Staff.fromJson(data);
        _staffs.add(newStaff);
        tableController.insert(newStaff);
        tableController.refresh();
        print('socket added new staff');
        notifyListeners();

        break;
      case 'UPDATE':
        final index = _staffs.indexWhere((a) => a.id == data['_id']);

        if (index != -1) {
          _staffs[index] = Staff.fromJson(data);
          tableController.refresh();
          tableController.replace(index, _staffs[index]);

          notifyListeners();
        }
        break;
      case 'DELETE':
        print('Received DELETE message: $data');
        final idToDelete = data;
        final staffToRemove = _staffs.firstWhere(
          (a) => a.id == idToDelete,
          orElse: () {
            throw Exception('Staff not found for id: $idToDelete');
          },
        );
        if (staffToRemove != null) {
          _staffs.remove(staffToRemove);
          tableController.removeRow(staffToRemove);
          tableController.refresh();
          print('socket removed staff');
        } else {
          print('staff not found for id: $idToDelete');
        }
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  Future<void> fetchStaffs() async {
    try {
      final response = await http.get(Uri.parse(Const.staffUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _staffs =
            data.map((json) => Staff.fromJson(json)).toList();

        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error fetching Staffs: $error');
      throw error;
    }
  }

  // Future<void> addAnniversary(
  //   Anniversary anniversary,
  //   List<TextEditingController> controllers,
  // ) async {
  //   try {
  //     _loading = true;
  //     final response = await http.post(
  //       Uri.parse(Const.anniversaryUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(anniversary.toJson()),
  //     );
  //     if (response.statusCode == 201) {
  //       Fluttertoast.showToast(
  //         msg: "Anniversary added successfully!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         backgroundColor: Colors.green,
  //         textColor: Colors.white,
  //       );

  //       // Clear all controllers
  //       for (var controller in controllers) {
  //         controller.clear();
  //       }
  //       // _selectedPaperType = null;
  //       // _selectedType = null;
  //       // _compressedImage = null;
  //       _selectedDate = null;
  //       _anniversaryYear = null;
  //       notifyListeners();
  //     } else {
  //       throw Exception('Failed to add anniversary' + response.body);
  //     }
  //   } catch (error) {
  //     Fluttertoast.showToast(
  //       msg: error.toString(),
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //     );
  //     print('Error adding anniversary: $error');
  //   } finally {
  //     _loading = false;
  //   }
  // }

  Future<void> updateStaff(
      Staff staff, BuildContext context) async {
    _updateLoading = true;
    notifyListeners();
    try {
      final response = await http.patch(
        Uri.parse('${Const.staffUrl}/${staff.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(staff.toJson()),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anniversary updated successfully!')),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to update anniversary: ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      _updateLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSelectedStaffs(
      BuildContext context, List<Staff> selectedStaffs) async {
    try {
      for (var staff in selectedStaffs) {
        deleteStaff(context, staff);
      }
      notifyListeners();
    } catch (error) {
      print('Error deleting selected clients and their extras: $error');
    }
  }

  Future<void> deleteStaff(
      BuildContext context, Staff staff) async {
    try {
      final response = await http
          .delete(Uri.parse('${Const.staffUrl}/${staff.id}'));
      if (response.statusCode == 200) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Fluttertoast.showToast(
          msg: "Deleted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        notifyListeners();
      } else {
        throw Exception('Failed to delete staff ${response.body}');
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Error deleting staff: $error');
      throw error;
    }
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    _anniversaryYear = DateTime.now().year - date.year;
    _isAnniversaryYearEnabled = true;
    notifyListeners();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
