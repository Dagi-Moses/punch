import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/anniversarySector.dart';
import 'package:punch/models/myModels/anniversaryTypeModel.dart';
import 'package:punch/models/myModels/papers.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:paged_datatable/paged_datatable.dart';

class AnniversaryProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000/anniversaries';
  final String base = "http://localhost:3000";
  late WebSocketChannel channel;
  List<Anniversary> _anniversaries = [];
  List<Anniversary> get anniversaries => _anniversaries;
  List<AnniversarySector> _anniversarySectors = [];
  List<AnniversarySector> get anniversarySectors => _anniversarySectors;

  final String webSocketUrl = 'ws://localhost:3000?channel=anniversary';
  bool _loading = false; // Default value

  bool get loading => _loading;
  //  Uri.parse('ws://localhost:3000?channel=anniversary'),

  bool _isRowsSelected = false; // Default value
  bool get isRowsSelected => _isRowsSelected;

  Map<int, String> _anniversaryTypes = {}; // Map to store type descriptions
  Map<int, String> _paperTypes = {}; // Map to store paper descriptions

  Map<int, String> get anniversaryTypes => _anniversaryTypes;
  Map<int, String> get paperTypes => _paperTypes;
  // Method to fetch anniversary types from the database

  Future<void> fetchAnniversaryTypes() async {
    try {
      final response = await http.get(Uri.parse("$base/anniversaryTypes"));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var anniversaryType = AnniversaryType.fromJson(item);
          _anniversaryTypes[anniversaryType.anniversaryTypeId] =
              anniversaryType.description;
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

  // Method to fetch paper types from the database
  Future<void> fetchPaperTypes() async {
    try {
      final response = await http.get(Uri.parse("$base/papers"));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var paperType = Papers.fromJson(item);
          _paperTypes[paperType.paperId] = paperType.description;
        }

        // Notify listeners after updating the anniversary types
        notifyListeners();
      } else {
        throw Exception('Failed to load anniversary types');
      }
    } catch (error) {
      // Handle errors, e.g., log them or show a message to the user
      print('Error fetching anniversary types: $error');
    }
  }

  // Method to get anniversary type description by ID
  String getAnniversaryTypeDescription(int? typeId) {
    return _anniversaryTypes[typeId] ?? 'Unknown';
  }

  // Method to get paper type description by ID
  String getPaperTypeDescription(int? paperId) {
    return _paperTypes[paperId] ?? 'Unknown';
  }

  Future<void> addAnniversaryType(
      TextEditingController descriptionController) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("$base/anniversaryTypes"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 201) {
        fetchAnniversaryTypes();
        descriptionController.clear();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error adding anniversary type: $error');
    }
  }

  Future<void> addPaperType(TextEditingController descriptionController) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("$base/papers"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 201) {
        fetchPaperTypes();
        descriptionController.clear();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error adding paper type: $error');
    }
  }

  Future<void> updateAnniversaryType(
    int id,
    TextEditingController descriptionController,
    void Function() clearSelectedType,
  ) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse("$base/anniversaryTypes/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 200) {
        fetchAnniversaryTypes();
        descriptionController.clear();
        clearSelectedType();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error updating anniversary type: $error');
    }
  }

  Future<void> updatePaperType(
    int id,
    TextEditingController descriptionController,
    void Function() clearSelectedType,
  ) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse("$base/papers/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 200) {
        fetchPaperTypes();
        descriptionController.clear();
        clearSelectedType();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error updating anniversary type: $error');
    }
  }

  Future<void> deleteAnniversaryType(
      BuildContext context, int anniversaryTypeId) async {
    // Update with your actual base URL

    try {
      final response = await http.delete(
        Uri.parse('$base/anniversaryTypes/$anniversaryTypeId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await anniversaryTypes.remove(anniversaryTypeId);
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

  Future<void> deletePaperType(BuildContext context, int paperTypeId) async {
    // Update with your actual base URL

    try {
      final response = await http.delete(
        Uri.parse('$base/papers/$paperTypeId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await paperTypes.remove(paperTypeId);
        notifyListeners();
        Navigator.pop(context);

        print('papers deleted successfully');
      } else {
        // Handle the error response
        throw Exception('Failed to delete paper type: ${response.body}');
      }
    } catch (error) {
      print('Error deleting anniversary type: $error');
      // Handle exceptions here
    }
  }

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  late WebSocketManager _webSocketManager;
  final tableController = PagedDataTableController<String, Anniversary>();

  AnniversaryProvider() {
    channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000?channel=anniversary'));
    fetchAnniversaries();
    _initializeWebSocket();
    fetchAnniversaryTypes();
    fetchPaperTypes();
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

  void _handleWebSocketMessage(dynamic message) async {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        // Directly add the new anniversary to the list
        final newAnniversary = Anniversary.fromJson(data);
        _anniversaries.add(newAnniversary);
        tableController.insert(newAnniversary);
        tableController.refresh();
        print('socket added new anniversary');
        notifyListeners();

        break;
      case 'UPDATE':
        final index = _anniversaries.indexWhere((a) => a.id == data['_id']);

        if (index != -1) {
          _anniversaries[index] = Anniversary.fromJson(data);
          tableController.refresh();
          tableController.replace(index, _anniversaries[index]);

          notifyListeners();
        }
        break;
      case 'DELETE':
        print('Received DELETE message: $data');
        final idToDelete = data;
        final anniversaryToRemove = _anniversaries.firstWhere(
          (a) => a.id == idToDelete,
          orElse: () {
            throw Exception('Anniversary not found for id: $idToDelete');
          },
        );
        if (anniversaryToRemove != null) {
          _anniversaries.remove(anniversaryToRemove);
          tableController.removeRow(anniversaryToRemove);
          tableController.refresh();
          print('socket removed anniversary');
        } else {
          print('Anniversary not found for id: $idToDelete');
        }

        //print('socket removed anniversary ' + indexToRemove.toString());
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  Future<void> fetchAnniversaries() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _anniversaries =
            data.map((json) => Anniversary.fromJson(json)).toList();
        print("anniversary fetched from web socket");
        notifyListeners();
      } else {
        throw Exception('Failed to load anniversaries');
      }
    } catch (error) {
      print('Error fetching anniversaries: $error');
      throw error;
    }
  }

  Future<void> fetchAnniversarySectors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/anniversarySectors"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _anniversarySectors =
            data.map((json) => AnniversarySector.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load anniversary sectors');
      }
    } catch (error) {
      print('Error fetching anniversary sectors: $error');
    }
  }

  Future<void> addAnniversary(
    Anniversary anniversary,
    List<TextEditingController> controllers,
    void Function() clearSelectedType,
  ) async {
    try {
      _loading = true;
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Anniversary added successfully!",
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
        _selectedDate = null;
        notifyListeners();
      } else {
        throw Exception('Failed to add anniversary' + response.body);
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Error adding anniversary: $error');
    } finally {
      _loading = false;
    }
  }

  Future<void> updateAnniversary(
      Anniversary anniversary, BuildContext context) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/${anniversary.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
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
    }
  }

  Future<void> deleteSelectedAnniversaries(
      BuildContext context, List<Anniversary> selectedAnniversaries) async {
    try {
      print("selectedClients ${selectedAnniversaries.length.toString()}");
      // Iterate over the selected clients
      for (var anniversary in selectedAnniversaries) {
        // Await the deletion of the client
        deleteAnniversary(context, anniversary.id!);
      }

      // Notify listeners after all deletions are completed
      notifyListeners();
    } catch (error) {
      print('Error deleting selected clients and their extras: $error');
    }
  }

  Future<void> deleteAnniversary(BuildContext context, String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
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
        throw Exception('Failed to delete anniversary ' + response.body);
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Error deleting anniversary: $error');
      throw error;
    }
  }

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
