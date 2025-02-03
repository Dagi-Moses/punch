import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker_web/image_picker_web.dart';

import 'package:paged_datatable/paged_datatable.dart';
import 'package:provider/provider.dart';
import 'package:punch/functions/imageFunctions.dart';
import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/models/myModels/titleModel.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:punch/providers/clientExtraProvider.dart';
import 'package:punch/src/const.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ClientProvider with ChangeNotifier {
  // final ImagePicker _picker = ImagePicker();
  final tableController = PagedDataTableController<String, Client>();

  late WebSocketChannel channel;

  List<Client> _clients = [];
  List<Client> get clients => _clients;

  bool _isRowsSelected = false; // Default value
  bool get isRowsSelected => _isRowsSelected;

  bool _loading = false; // Default value
  bool get loading => _loading;

  bool _updateLoading = false; // Default value
  bool get updateloading => _updateLoading;

  bool _imageLoading = false;
  bool get imageLoading => _imageLoading;

  int? _selectedType;
  int? get selectedType => _selectedType;

  int? _age;
  int? get age => _age;

  Uint8List? _compressedImage;
  Uint8List? get compressedImage => _compressedImage;

  String? _query;
  String? get query => _query;

  set imageLoading(bool newValue) {
    _imageLoading = newValue;
    notifyListeners();
  }

  void setQuery(String? newQuery) {
    if (_query != newQuery) {
      _query = newQuery;
      notifyListeners();
    }
  }

  set compressedImage(Uint8List? newValue) {
    _compressedImage = newValue;
    notifyListeners();
  }

  set selectedType(int? newValue) {
    _selectedType = newValue;
    notifyListeners();
  }

  Future<Uint8List?> pickImage() async {
    _imageLoading = true;
    notifyListeners();
    try {
      final Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();
      // Start loading

      if (imageBytes != null) {
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

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  late WebSocketManager _webSocketManager;
  ClientProvider() {
    fetchClients();
    _initializeWebSocket();
 
  }
 
  void _initializeWebSocket() {
    _webSocketManager = WebSocketManager(
      Const.clientChannel,
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
        final newClient = Client.fromJson(data);
        _clients.add(newClient);
        tableController.insert(newClient);
        tableController.refresh();
        print('socket added new client');
        notifyListeners();
        break;
      case 'UPDATE':
        try {
          final index = _clients.indexWhere((a) => a.id == data['_id']);
          if (index != -1) {
            print("hmm");
            _clients[index] = Client.fromJson(data);
            tableController.refresh();
            tableController.replace(index, _clients[index]);

            print('socket updated client');
            notifyListeners();
          }
        } catch (e) {
          print(e);
        }

        break;
      case 'DELETE':
        print('Received DELETE message: $data');
        final idToDelete = data;
        final clientToRemove = _clients.firstWhere(
          (a) => a.id == idToDelete,
          orElse: () {
            throw Exception('Client not found for id: $idToDelete');
          },
        );
        if (clientToRemove != null) {
          _clients.remove(clientToRemove);
          tableController.removeRow(clientToRemove);
          tableController.refresh();
          print('socket removed client');
        } else {
          print('Client not found for id: $idToDelete');
        }
        notifyListeners();
        break;
    }
  }

  Future<void> deleteSelectedClients(
      BuildContext context, List<Client> selectedClients) async {
    try {
      for (var client in selectedClients) {
        deleteClient(context, client);

        ClientExtra? clientExtra =
            Provider.of<ClientExtraProvider>(context, listen: false)
                .clientsExtraMap[client.clientNo];

        if (clientExtra != null) {
          deleteClientExtra(context, clientExtra.id!);
        }
      }

      notifyListeners();
    } catch (error) {
      print('Error deleting selected clients and their extras: $error');
    }
  }

  Future<void> deleteClientExtra(BuildContext context, String id) async {
    try {
      print("started deleting extras $id");
      final response =
          await http.delete(Uri.parse('${Const.clientExtraUrl}/$id'));
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

  Future<void> fetchClients() async {
    try {
      final response = await http.get(Uri.parse(Const.clientUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _clients = data.map((json) => Client.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load company Extras: ' + response.body);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addClient(
    Client client,
    ClientExtra clientExtra,
    List<TextEditingController> controllers,
  ) async {
    try {
      _loading = true;
      notifyListeners();
      final response = await http.post(
        Uri.parse(Const.clientUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'client': client.toJson(), 'clientExtra': clientExtra.toJson()}),
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Client added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        for (var controller in controllers) {
          controller.clear();
        }
        _selectedType = null;
        _compressedImage = null;
        _age = null;
        notifyListeners();
      } else {
        throw Exception('Failed to add client ' + response.body);
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

  Future<void> updateClient(Client client, ClientExtra clientExtra,
      Function onSuccess, BuildContext context) async {
    _updateLoading = true;
    notifyListeners();
    try {
      print("started");
      final response = await http.patch(
        Uri.parse('${Const.clientUrl}/${client.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(client.toJson()),
      );
      final responseExtra = await http.patch(
        Uri.parse('${Const.clientExtraUrl}/${clientExtra.clientNo}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(clientExtra.toJson()),
      );
      if (response.statusCode == 200 && responseExtra.statusCode == 200) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client updated successfully!')),
        );
        notifyListeners();
      } else {
        throw Exception(
            {"response": response.body + "\n REspondata" + responseExtra.body});
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    } finally {
      _updateLoading = false;
      notifyListeners();
    }
  }
  // }

  // // Future<void> updateClient(Client client, ClientExtra clientExtra,
  //     Function onSuccess, BuildContext context) async {
  //   print("starting client: ${client.toJson().toString()}");
  //   print("client Id: ${client.id}");
  //   try {
  //     print("started");
  //     final response = await http.patch(
  //       Uri.parse('$baseUrl/${client.id}'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(client.toJson()),
  //     );

  //     if (response.statusCode == 200 ) {
  //       onSuccess();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Client updated successfully!')),
  //       );
  //       notifyListeners();
  //     } else {
  //       throw Exception(
  //           response.body );
  //     }
  //   } catch (err) {
  //     print(err);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(err.toString())),
  //     );
  //   }
  // }

  Future<void> deleteClient(BuildContext context, Client client) async {
    try {
      final response =
          await http.delete(Uri.parse('${Const.clientUrl}/${client.id}'));
      if (response.statusCode == 200) {
        ClientExtra? clientExtra =
            Provider.of<ClientExtraProvider>(context, listen: false)
                .clientsExtraMap[client.clientNo];
        // If a client extra exists, await its deletion
        if (clientExtra != null) {
          deleteClientExtra(context, clientExtra.id!);
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

  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;
  void setDate(DateTime date) {
    _selectedDate = date;

    // Calculate the age based on the year, month, and day
    DateTime now = DateTime.now();
    int age = now.year - date.year;

    // Adjust the age if the birthday hasn't occurred yet this year
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    _age = age; // Set the adjusted age
    notifyListeners(); // Notify listeners of the change
  }

  DateTime? _selectedStartDate;

  DateTime? get selectedStartDate => _selectedStartDate;

  void setStartDate(DateTime date) {
    _selectedStartDate = date;
    notifyListeners();
  }

  // @override
  // void dispose() {
  //   channel.sink.close();
  //   super.dispose();
  // }
  @override
  void dispose() {
    channel.sink.close(); // Clean up WebSocket
    tableController.dispose(); // Clean up table controller
    super.dispose();
  }
}
