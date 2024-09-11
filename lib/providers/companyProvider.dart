import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:paged_datatable/paged_datatable.dart';
import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/models/myModels/companySectorModel.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:punch/providers/clientExtraProvider.dart';

class CompanyProvider with ChangeNotifier {
  final String baseUrl = 'http://172.20.20.28:3000/companies';
  final String base = "http://172.20.20.28:3000";
  List<Company> _companies = [];
  List<Company> get companies => _companies;
  Map<int, CompanyExtra> companyExtraMap = {};
  bool _isRowsSelected = false; // Default value
  bool get isRowsSelected => _isRowsSelected;
  bool _loading = false; // Default value
  bool get loading => _loading;
  final String webSocketUrl = 'ws://172.20.20.28:3000?channel=client';
  final tableController = PagedDataTableController<String, Company>();

  // Two WebSocket URLs
  final String companyWebSocketUrl = 'ws://172.20.20.28:3000?channel=company';
  final String companyExtraWebSocketUrl =
      'ws://172.20.20.28:3000?channel=companyExtra';

  late WebSocketManager _companyWebSocketManager;
  late WebSocketManager _companyExtraWebSocketManager;

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
      companyWebSocketUrl,
      _handleCompanyWebSocketMessage,
      _reconnectCompanyWebSocket,
    );
    _companyWebSocketManager.connect();

    // Initialize WebSocket for CompanyExtra
    _companyExtraWebSocketManager = WebSocketManager(
      companyExtraWebSocketUrl,
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
      final response = await http.get(Uri.parse("$base/companySectors"));

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
        Uri.parse("$base/companySectors"),
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
        Uri.parse("$base/companySectors/$id"),
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
        Uri.parse('$base/companySectors/$anniversaryTypeId'),
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
      final response = await http.get(Uri.parse(baseUrl));
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
      final response = await http.get(Uri.parse("$base/companyExtras"));
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
        print("company Extras lenght " + companyExtraMap.length.toString());
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
    void Function() clearSelectedType,
  ) async {
    
    try {
      print('started');
      // Create the combined payload
      _loading = true;
      final payload = {
        'company': company.toJson(),
        'companyExtra': companyExtra.toJson(),
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(baseUrl),
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
        clearSelectedType();

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
      final response = await http.get(Uri.parse('$baseUrl/$id'));

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
    Function onSuccess,
    BuildContext context,
  ) async {
    print('started');
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/${company.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(company.toJson()),
      );
      final responseExtra = await http.patch(
        Uri.parse('$base/companyExtras/${companyExtra.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(companyExtra.toJson()),
      );
       
      if (response.statusCode == 200 && responseExtra.statusCode == 200) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company updated successfully!')),
        );
        notifyListeners();
      } else {
        throw Exception(
            {"response": response.body + " REspondata" + responseExtra.body});
      }
    } catch (error) {
      print(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
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
      final response = await http.delete(Uri.parse('$baseUrl/${company.id}'));
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
      final response = await http.delete(Uri.parse('$base/companyExtras/$id'));
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
