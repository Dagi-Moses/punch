import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/models/myModels/companySectorModel.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class CompanyProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000/companies';
  final String base = "http://localhost:3000";
  late WebSocketChannel channel;
  List<Company> _companies = [];
  List<Company> get companies => _companies;
  List<CompanySector> _companySectors = [];
  List<CompanySector> get companySectors => _companySectors;
  List<CompanyExtra> _companyExtras = [];
  List<CompanyExtra> get companyExtras => _companyExtras;
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

  CompanyProvider() {
    fetchCompanies();

    _initializeWebSocket();
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

  Future<void> fetchCompanySectors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/companySectors"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _companySectors =
            data.map((json) => CompanySector.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load anniversaries');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> addCompany(
    Company company,
    CompanyExtra companyExtra,
    List<TextEditingController> controllers,
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

  Future<void> updateCompany(String id, Company company) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(company.toJson()),
      );
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update anniversary');
      }
    } catch (error) {
      throw error;
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
