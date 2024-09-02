import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/models/myModels/companySectorModel.dart';
import 'package:punch/models/myModels/companyWithExtra.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class CompanyProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000/companies';
  final String base = "http://localhost:3000";
  late WebSocketChannel channel;
  List<Company> _companies = [];
  List<Company> get companies => _companies;
  
  List<CompanyExtra> _companyExtras = [];
  List<CompanyExtra> get companyExtras => _companyExtras;

  List<CompanyWithExtra> _mergedCompanyWithExtras = [];
  List<CompanyWithExtra> get mergedCompanyWithExtras =>
      _mergedCompanyWithExtras;
  bool _isRowsSelected = false; // Default value

  bool get isRowsSelected => _isRowsSelected;
  bool _loading = false; // Default value

  bool get loading => _loading;
 
  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  final String webSocketUrl = 'ws://localhost:3000?channel=company';

  late WebSocketManager _webSocketManager;


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



  CompanyProvider() {
    _initialize();

    _initializeWebSocket();
    fetchCompanySectors();
  }

  Future<void> _initialize() async {
    await Future.wait([fetchCompanies(), fetchCompanyExtras()]);

    _mergeCompanyWithExtras();
  }

  void _initializeWebSocket() {
    _webSocketManager = WebSocketManager(
      webSocketUrl,
      _handleWebSocketMessage,
      _reconnectWebSocket,
    );
    _webSocketManager.connect();
  }

  void _reconnectWebSocket() {
    print("reconnected");
  }

  void _handleWebSocketMessage(dynamic message) {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        // _anniversaries.add(Anniversary.fromJson(data));

        fetchCompanies();
        fetchCompanyExtras();
        notifyListeners();
        break;
      case 'UPDATE':
        final index = _companies.indexWhere((a) => a.id == data['id']);
        if (index != -1) {
          _companies[index] = Company.fromJson(data);
          notifyListeners();
        }
        break;
      case 'DELETE':
        // _anniversaries.removeWhere((a) => a.id == data);
        fetchCompanies();
        fetchCompanyExtras();
        notifyListeners();
        break;
    }
    notifyListeners();
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
    try {
      final response = await http.get(Uri.parse("$base/companyExtras"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _companyExtras =
            data.map((json) => CompanyExtra.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load company Extras: ' + response.body);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }
  bool _loadingMerged = false; // Default value

  bool get loadingMerged => _loadingMerged;

  Future<void> _mergeCompanyWithExtras() async {
    _loadingMerged  = true;
    notifyListeners();
    _mergedCompanyWithExtras = _companies.map((company) {
      // Attempt to find the matching user record
      final matchingRecord = _companyExtras.firstWhere(
        (record) => record.companyNo == company.id,
        orElse: () =>
            CompanyExtra(), // Return an empty UserRecord if no match is found
      );
      // Check if the matchingRecord is not empty
      if (matchingRecord.companyNo != null) {
        // If a matching record was found, merge it with the user
        return CompanyWithExtra(company: company, companyExtra: matchingRecord);
      } else {
        // If no matching record was found, just return the user with an empty UserRecord
        return CompanyWithExtra(company: company, companyExtra: CompanyExtra());
      }
    }).toList();
_loadingMerged  = false;
  
    notifyListeners();
  }

 

  Future<void> addCompany(
    Company company,
    CompanyExtra companyExtra,
    List<TextEditingController> controllers,
     void Function() clearSelectedType,
  ) async {
    try {
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

  // Future<void> addTestCompany() async {
  //   DateTime today = DateTime.now();
  //   DateTime previousYear = DateTime(today.year - 1, today.month, today.day);
  //   var random = Random();
  //   int randomNumber = random.nextInt(30);
  //   // Company company = Company(
  //   //     placedByName: "test",
  //   //     paperId: randomNumber,
  //   //     friends: "test",
  //   //     placedByPhone: '08181304896',
  //   //     placedByAddress: "test",
  //   //     name: "TestName",
  //   //     date: previousYear,
  //   //     associates: "Test associates",
  //   //     anniversaryYear: 2023,
  //   //     anniversaryNo: randomNumber,
  //   //     anniversaryTypeId: AnniversaryType.other);
  //   try {
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(company.toJson()),
  //     );
  //     if (response.statusCode == 201) {
  //       showToaster(
  //         "Anniversary added successfully!",
  //         Toast.LENGTH_LONG,
  //         Colors.green,
  //       );

  //       notifyListeners();
  //     } else {
  //       throw Exception(response.body);
  //     }
  //   } catch (error) {
  //     showToaster(
  //       error.toString(),
  //       Toast.LENGTH_LONG,
  //       Colors.red,
  //     );

  //     throw error;
  //   }
  // }

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

  Future<void> updateCompany(Company company, CompanyExtra companyExtra) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/${company.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(company.toJson()),
      );
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update anniversary');
      }
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> deleteCompany(BuildContext context, String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        //  Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "deleted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        notifyListeners();
      } else {
        throw Exception('Failed to delete anniversary');
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

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
