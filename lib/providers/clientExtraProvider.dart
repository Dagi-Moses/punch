import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ClientExtraProvider with ChangeNotifier {
  final String baseUrl = 'http://172.20.20.28:3000/clientExtras';
  final String base = "http://172.20.20.28:3000";
  //late WebSocketChannel channel;
  final String webSocketUrl = 'ws://172.20.20.28:3000?channel=clientExtra';
  late WebSocketManager _webSocketManager;
  Map<int, ClientExtra> clientsExtraMap = {};
  ClientExtraProvider() {
    fetchClientExtras();
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
        final newClientExtra = ClientExtra.fromJson(data);
        if (newClientExtra.clientNo != null) {
          clientsExtraMap[newClientExtra.clientNo!] = newClientExtra;
          print('socket added new Client Extra');
          notifyListeners();
        }
        break;

      case 'UPDATE':
        final clientNo = data['Client_No'];
        if (clientNo != null) {
          // Check if the clientNo already exists in the map
          if (clientsExtraMap.containsKey(clientNo)) {
            // Update the existing client extra
            clientsExtraMap[clientNo] = ClientExtra.fromJson(data);
            print('socket updated Client Extra');
          } else {
            // Add the new client extra if not found
            clientsExtraMap[clientNo] = ClientExtra.fromJson(data);
            print('socket added new Client Extra');
          }
          notifyListeners();
        }
        break;

      case 'DELETE':
        final clientNoToDelete = data;
        if (clientsExtraMap.containsKey(clientNoToDelete)) {
          clientsExtraMap.remove(clientNoToDelete);
          print('socket removed client Extra');
          notifyListeners();
        } else {
          print('Client extra not found for clientNo: $clientNoToDelete');
        }
        break;

      default:
        print('Unhandled message type: $type');
        break;
    }
  }

  ClientExtra? getClientExtraByClientNo(int clientNo) {
    return clientsExtraMap[clientNo];
  }

  // Optional: Method to add or update a ClientExtra
  void addOrUpdateClientExtra(ClientExtra clientExtra) {
    if (clientExtra.clientNo != null) {
      clientsExtraMap[clientExtra.clientNo!] = clientExtra;
      notifyListeners();
    }
  }

  Future<void> fetchClientExtras() async {
    print("started fetching clientExtras");
    try {
      final response = await http.get(Uri.parse("$base/clientExtras"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Clear the existing map to prevent old data from lingering
        clientsExtraMap.clear();

        // Populate the map with the fetched data
        for (var json in data) {
          final clientExtra = ClientExtra.fromJson(json);
          if (clientExtra.clientNo != null) {
            clientsExtraMap[clientExtra.clientNo!] = clientExtra;
          }
        }
   print("client Extras lenght " + clientsExtraMap.length.toString());
        // Notify listeners about the change
        notifyListeners();
      } else {
        print(response.body);
        throw Exception('Failed to load client Extras: ${response.body}');
      }
    } catch (error) {
      print('Error fetching client extras: $error');
      throw error;
    }
  }

  Future<void> addClientExtra(
    ClientExtra clientExtra,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(clientExtra.toJson()),
      );
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Client Extra added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        notifyListeners();
      } else {
        throw Exception('Failed to add clientExtra ' + response.body);
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
    }
  }

  Future<void> updateClientExtra(
      ClientExtra clientExtra, BuildContext context) async {
    try {
      print("started extra");
      final response = await http.patch(
        Uri.parse('$baseUrl/${clientExtra.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(clientExtra.toJson()),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client updated successfully!')),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to update clientExtra' + response.body);
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  Future<void> deleteClientExtra(BuildContext context, String id) async {
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
        // if (Navigator.canPop(context)) {
        //   Navigator.pop(context);
        // }
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

}
