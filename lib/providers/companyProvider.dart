import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:punch/functions/imageFunctions.dart';
import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/models/myModels/companySectorModel.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:punch/providers/clientExtraProvider.dart';
import 'package:punch/src/const.dart';

class CompanyProvider with ChangeNotifier {
  List<Company> _companies = [];
  List<Company> get companies => _companies;
  Map<int, CompanyExtra> companyExtraMap = {};
  bool _isRowsSelected = false; // Default value
  bool get isRowsSelected => _isRowsSelected;
  bool _loading = false; // Default value
  bool get loading => _loading;

  bool _imageLoading = false;
  bool get imageLoading => _imageLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  bool _updateLoading = false;
  bool get updateloading => _updateLoading;

  final tableController = PagedDataTableController<String, Company>();

  late WebSocketManager _companyWebSocketManager;
  late WebSocketManager _companyExtraWebSocketManager;

  String? _query;
  String? get query => _query;

  void setQuery(String? newQuery) {
    if (_query != newQuery) {
      _query = newQuery;
      notifyListeners();
    }
  }

  int? _selectedType;
  int? get selectedType => _selectedType;

  set selectedType(int? newValue) {
    _selectedType = newValue;
    notifyListeners();
  }

  set isEditing(bool newValue) {
    _isEditing = newValue;
    notifyListeners();
  }

  Uint8List? _compressedImage;
  Uint8List? get compressedImage => _compressedImage;

  set compressedImage(Uint8List? newValue) {
    _compressedImage = newValue;
    notifyListeners();
  }

  Future<Uint8List?> pickImage() async {
    _imageLoading = true;
    notifyListeners();
    try {
      final Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();

      if (imageBytes != null) {
        _imageLoading = true; // Start loading
        notifyListeners();
        final Uint8List? compressed = await compressToTargetSize(
          imageBytes,
          5,
        );

        if (compressed != null) {
          _compressedImage = compressed;
          notifyListeners();
          return compressed;
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      _imageLoading = false; // Stop loading
      notifyListeners();
    }

    return null;
  }

  CompanyProvider() {
    fetchCompanies();
    fetchCompanyExtras();
    _initializeWebSockets();
    fetchCompanySectors();
  }

  // Initialization method for both WebSockets
  void _initializeWebSockets() {
    // Initialize WebSocket for Company
    _companyWebSocketManager = WebSocketManager(
      Const.companyChannel,
      _handleCompanyWebSocketMessage,
      _reconnectCompanyWebSocket,
    );
    _companyWebSocketManager.connect();

    // Initialize WebSocket for CompanyExtra
    _companyExtraWebSocketManager = WebSocketManager(
      Const.companyExtraChannel,
      _handleCompanyExtraWebSocketMessage,
      _reconnectCompanyExtraWebSocket,
    );
    _companyExtraWebSocketManager.connect();
  }

  void _reconnectCompanyWebSocket() {
    print("Company WebSocket reconnected");
  }

  void _reconnectCompanyExtraWebSocket() {
    print("CompanyExtra WebSocket reconnected");
  }

  // Handle messages from Company WebSocket
  void _handleCompanyWebSocketMessage(dynamic message) {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        final newCompany = Company.fromJson(data);
        _companies.add(newCompany);
        tableController.insert(newCompany);
        tableController.refresh();
        print('socket added new company');
        notifyListeners();
        break;
      case 'UPDATE':
        try {
          final index = _companies.indexWhere((a) => a.id == data['_id']);
          if (index != -1) {
            _companies[index] = Company.fromJson(data);
            tableController.refresh();
            tableController.replace(index, _companies[index]);

            print('socket updated company ');
            notifyListeners();
          }
        } catch (e) {
          print(e);
        }

        break;
      case 'DELETE':
        print('Received DELETE message: $data');
        final idToDelete = data;
        final clientToRemove = _companies.firstWhere(
          (a) => a.id == idToDelete,
          orElse: () {
            throw Exception('Company not found for id: $idToDelete');
          },
        );
        if (clientToRemove != null) {
          _companies.remove(clientToRemove);
          tableController.removeRow(clientToRemove);
          tableController.refresh();
          print('socket removed client');
        } else {
          print('Client not found for id: $idToDelete');
        }
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  // Handle messages from CompanyExtra WebSocket
  void _handleCompanyExtraWebSocketMessage(dynamic message) {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        final newClientExtra = CompanyExtra.fromJson(data);
        if (newClientExtra.companyNo != null) {
          companyExtraMap[newClientExtra.companyNo!] = newClientExtra;
          print('socket added new Company Extra');
          notifyListeners();
        }
        break;
      case 'UPDATE':
        final clientNo = data['Company_No'];
        if (clientNo != null) {
          // Check if the clientNo already exists in the map
          if (companyExtraMap.containsKey(clientNo)) {
            // Update the existing client extra
            companyExtraMap[clientNo] = CompanyExtra.fromJson(data);
            print('socket updated Company Extra');
          } else {
            // Add the new client extra if not found
            companyExtraMap[clientNo] = CompanyExtra.fromJson(data);
            print('socket added new Company Extra');
          }
          notifyListeners();
        }
        break;

      case 'DELETE':
        final clientNoToDelete = data;
        if (companyExtraMap.containsKey(clientNoToDelete)) {
          companyExtraMap.remove(clientNoToDelete);
          print('socket removed company Extra');
          notifyListeners();
        } else {
          print('Client extra not found for companyNo: $clientNoToDelete');
        }
        break;

      default:
        print('Unhandled message type: $type');
        break;
    }
    notifyListeners();
  }

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  CompanyExtra? getCompanyExtraByCompanyNo(int companyNo) {
    return companyExtraMap[companyNo];
  }

  Map<int, String> _companySectors = {}; // Map to store type descriptions

  Map<int, String> get companySectors => _companySectors;

  Future<void> fetchCompanySectors() async {
    try {
      final response = await http.get(Uri.parse(Const.companySectorUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var companySectorType = CompanySector.fromJson(item);
          _companySectors[companySectorType.companySectorId] =
              companySectorType.description;
        }

        // Notify listeners after updating the anniversary types
        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      // Handle errors, e.g., log them or show a message to the user
      print('Error fetching anniversary types: $error');
    }
  }

  // Method to get anniversary type description by ID
  String getCompanySectorDescription(int? typeId) {
    return _companySectors[typeId] ?? 'Unknown';
  }

  Future<void> addCompanySector(
      TextEditingController descriptionController) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(Const.companySectorUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 201) {
        fetchCompanySectors();
        descriptionController.clear();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error adding anniversary type: $error');
    }
  }

  Future<void> updateCompanySector(
    int id,
    TextEditingController descriptionController,
    void Function() clearSelectedType,
  ) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse("${Const.companySectorUrl}/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 200) {
        fetchCompanySectors();
        descriptionController.clear();
        clearSelectedType();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error updating anniversary type: $error');
    }
  }

  Future<void> deleteCompanySector(
      BuildContext context, int anniversaryTypeId) async {
    // Update with your actual base URL

    try {
      final response = await http.delete(
        Uri.parse('${Const.companySectorUrl}/$anniversaryTypeId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await companySectors.remove(anniversaryTypeId);
        notifyListeners();
        Navigator.pop(context);

        print('Anniversary type deleted successfully');
      } else {
        // Handle the error response
        throw Exception('Failed to delete anniversary type: ${response.body}');
      }
    } catch (error) {
      print('Error deleting anniversary type: $error');
      // Handle exceptions here
    }
  }

  Future<void> fetchCompanies() async {
    try {
      final response = await http.get(Uri.parse(Const.companyUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _companies = data.map((json) => Company.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load company Extras: ' + response.body);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchCompanyExtras() async {
    print("started fetching clientExtras");
    try {
      final response = await http.get(Uri.parse(Const.companyExtraUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Clear the existing map to prevent old data from lingering
        companyExtraMap.clear();

        // Populate the map with the fetched data
        for (var json in data) {
          final companyExtra = CompanyExtra.fromJson(json);
          if (companyExtra.companyNo != null) {
            companyExtraMap[companyExtra.companyNo!] = companyExtra;
          }
        }
        print("company Extras lenght" + companyExtraMap.length.toString());
        // Notify listeners about the change
        notifyListeners();
      } else {
        print(response.body);
        throw Exception('Failed to load company Extras: ${response.body}');
      }
    } catch (error) {
      print('Error fetching client extras: $error');
      throw error;
    }
  }

  Future<void> addCompany(
    Company company,
    CompanyExtra companyExtra,
    List<TextEditingController> controllers,
  ) async {
    try {
   
      _loading = true;
        notifyListeners();
      final payload = {
        'company': company.toJson(),
        'companyExtra': companyExtra.toJson(),
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(Const.companyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      print(response.body);
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Company and Company Extra added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Clear all controllers
        for (var controller in controllers) {
          controller.clear();
        }
        _selectedType = null;
        _selectedDate = null;
        _selectedStartDate = null;
        _compressedImage = null;
        notifyListeners();
      } else {
        throw Exception('Failed to add company ' + response.body);
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print(error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchCompanyExtraById(String id) async {
    try {
      final response = await http.get(Uri.parse('${Const.companyUrl}/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null; // Handle not found
      } else {
        throw Exception('Failed to load company extra');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<void> updateCompany(
    Company company,
    CompanyExtra companyExtra,
    BuildContext context,
  ) async {
    _updateLoading = true;
    try {
      final response = await http.patch(
        Uri.parse('${Const.companyUrl}/${company.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(company.toJson()),
      );
      final responseExtra = await http.patch(
        Uri.parse('${Const.companyExtraUrl}/${companyExtra.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(companyExtra.toJson()),
      );

      if (response.statusCode == 200 && responseExtra.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company updated successfully!')),
        );
      } else {
        throw Exception(
            {"response": response.body + " REspondata" + responseExtra.body});
      }
    } catch (error) {
      print(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      _updateLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSelectedCompanies(
      BuildContext context, List<Company> selectedCompanies) async {
    print("object");
    try {
      print("selectedClients ${selectedCompanies.length.toString()}");
      // Iterate over the selected clients
      for (var client in selectedCompanies) {
        // Await the deletion of the client
        deleteCompany(context, client);
        // Fetch the associated client extra
        CompanyExtra? clientExtra = companyExtraMap[client.companyNo];
        // If a client extra exists, await its deletion
        if (clientExtra != null) {
          deleteCompanyExtra(context, clientExtra.id!);
        }
      }
      print("success");
      // Notify listeners after all deletions are completed
      notifyListeners();
    } catch (error) {
      print('Error deleting selected clients and their extras: $error');
    }
  }

  Future<void> deleteCompany(BuildContext context, Company company) async {
    try {
      print("started deleting extras ${company.toJson().toString()}");
      final response =
          await http.delete(Uri.parse('${Const.companyUrl}/${company.id}'));
      if (response.statusCode == 200) {
        CompanyExtra? companyExtra = companyExtraMap[company.companyNo];
        // If a client extra exists, await its deletion
        if (companyExtra != null) {
          deleteCompanyExtra(context, companyExtra.id!);
        }
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Fluttertoast.showToast(
          msg: "deleted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      throw error;
    }
  }

  Future<void> deleteCompanyExtra(BuildContext context, String id) async {
    try {
      print("started deleting extras $id");
      final response =
          await http.delete(Uri.parse('${Const.companyExtraUrl}/$id'));
      if (response.statusCode == 200) {
        print("deleted client extra");
        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print("client extra error $error");
      throw error;
    }
  }

  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  DateTime? _selectedStartDate;

  DateTime? get selectedStartDate => _selectedStartDate;

  void setStartDate(DateTime date) {
    _selectedStartDate = date;
    notifyListeners();
  }
}
