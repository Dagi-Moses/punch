import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/widgets/showToast.dart';
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

    channel.stream.listen(
      (message) {
        try {
          final decodedMessage = jsonDecode(message);
          handleWebSocketMessage(decodedMessage);
          print('decodedMessage: $decodedMessage'); // Fixed print statement
        } catch (e) {
          print('Error decoding message: $e');
        }
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket closed'),
    );
  }

  void handleWebSocketMessage(dynamic message) {
    final type = message['type'];
    final data = message['data'];

    switch (type) {
      case 'ADD':
        // _anniversaries.add(Anniversary.fromJson(data));

        fetchAnniversaries();
        print('socket refreshed anniversaries');
        notifyListeners();
        break;
      case 'UPDATE':
        final index = _anniversaries.indexWhere((a) => a.id == data['id']);
        if (index != -1) {
          _anniversaries[index] = Anniversary.fromJson(data);
          print('socket refreshed anniversaries');
          notifyListeners();
        }
        break;
      case 'DELETE':
        // _anniversaries.removeWhere((a) => a.id == data);
        fetchAnniversaries();
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

  Future<void> addTestAnniversary() async {
    DateTime today = DateTime.now();
    DateTime previousYear = DateTime(today.year - 1, today.month, today.day);
    var random = Random();
    int randomNumber = random.nextInt(30);
    Anniversary anniversary = Anniversary(
        placedByName: "test",
        paperId: randomNumber,
        friends: "test",
        placedByPhone: '08181304896',
        placedByAddress: "test",
        name: "TestName",
        date: previousYear,
        associates: "Test associates",
        anniversaryYear: 2023,
        anniversaryNo: randomNumber,
        anniversaryTypeId: randomNumber);
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 201) {
        showToaster(
          "Anniversary added successfully!",
          Toast.LENGTH_LONG,
          Colors.green,
        );

        notifyListeners();
      } else {
        print(response.body);
        throw Exception(response.body);
      }
    } catch (error) {
      showToaster(
        error.toString(),
        Toast.LENGTH_LONG,
        Colors.red,
      );

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
        print('Success');
      } else {
        throw Exception('Failed to update anniversary');
      }
    } catch (error) {
      print('Error updating anniversary: $error');
      throw error;
    }
  }

  Future<void> deleteAnniversary(BuildContext context, String id) async {
    try {
      print("aniversary id" + id);
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
        print(response.body);
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
