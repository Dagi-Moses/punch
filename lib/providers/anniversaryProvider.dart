import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/anniversaryModel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AnniversaryProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000/anniversaries';
  List<Anniversary> _anniversaries = [];
  late WebSocketChannel channel;
  List<Anniversary> get anniversaries => _anniversaries;
  AnniversaryProvider() {
    fetchAnniversaries();
    setupWebSocket();
  }
  bool _isRowsSelected = false; // Default value

  bool get isRowsSelected => _isRowsSelected;

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  void setupWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));

    channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      handleWebSocketMessage(decodedMessage);
    });
  }

  void handleWebSocketMessage(dynamic message) {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        _anniversaries.add(Anniversary.fromJson(data));
        break;
      case 'UPDATE':
        final index = _anniversaries.indexWhere((a) => a.id == data['id']);
        if (index != -1) {
          _anniversaries[index] = Anniversary.fromJson(data);
        }
        break;
      case 'DELETE':
        _anniversaries.removeWhere((a) => a.id == data);
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

  Future<void> addAnniversary(
    Anniversary anniversary,
    List<TextEditingController> controllers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 201) {
        _anniversaries.add(Anniversary.fromJson(jsonDecode(response.body)));
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
        throw Exception('Failed to add anniversary');
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
      throw error;
    }
  }

  Future<void> updateAnniversary(String id, Anniversary anniversary) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 200) {
        int index = _anniversaries
            .indexWhere((a) => a.anniversaryNo == anniversary.anniversaryNo);
        if (index != -1) {
          _anniversaries[index] =
              Anniversary.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update anniversary');
      }
    } catch (error) {
      print('Error updating anniversary: $error');
      throw error;
    }
  }

  Future<void> deleteAnniversary( BuildContext context,String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        _anniversaries.removeWhere((a) => a.anniversaryNo.toString() == id);
         Navigator.pop(context);
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
      print(error.toString());
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
