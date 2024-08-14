import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/anniversarySector.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

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

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }
  late WebSocketManager _webSocketManager;

  AnniversaryProvider() {
    channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000?channel=anniversary'));
    fetchAnniversaries();
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

  void _handleWebSocketMessage(dynamic message) async {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        await fetchAnniversaries();
        print('socket refreshed anniversaries');
        notifyListeners();
        break;
      case 'UPDATE':
        final index = _anniversaries.indexWhere((a) => a.id == data['id']);
        if (index != -1) {
          _anniversaries[index] = Anniversary.fromJson(data);
          print('socket updated anniversary');
          notifyListeners();
        }
        break;
      case 'DELETE':
        await fetchAnniversaries();
        print('socket refreshed anniversaries');
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

  Future<void> updateAnniversary(Anniversary anniversary) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/${anniversary.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 200) {
        print('Success');
        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error updating anniversary: $error');
      throw error;
    }
  }

  Future<void> deleteAnniversary(BuildContext context, String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Deleted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        Navigator.pop(context);
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
