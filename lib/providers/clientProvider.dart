import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
   final ImagePicker _picker = ImagePicker();
  late WebSocketChannel channel;
  List<Client> _clients = [];
  List<Client> get clients => _clients;
  final tableController = PagedDataTableController<String, Client>();

  bool _isRowsSelected = false; // Default value
  bool get isRowsSelected => _isRowsSelected;

  bool _loading = false; // Default value
  bool get loading => _loading;

  bool _updateLoading = false; // Default value
  bool get updateloading => _updateLoading;

  int? _selectedType;
  int? get selectedType => _selectedType;

  int? _age;
  int? get age => _age;

  Uint8List? _compressedImage;
  Uint8List? get compressedImage => _compressedImage;


  set compressedImage(Uint8List? newValue) {
    _compressedImage = newValue;
    notifyListeners();
  }
  

  set selectedType(int? newValue) {
    _selectedType = newValue;
    notifyListeners();
  }

  Future<Uint8List?> pickImage() async {
    // Pick the image
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Read the image as bytes
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      // Compress the image
      final Uint8List? compressedImage =
          await compressToTargetSize(imageBytes, 500);

      if (compressedImage != null) {
        _compressedImage = compressedImage;
        notifyListeners();
        return compressedImage;
      }
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
    fetchTitles();
  }
  Map<int, String> _titles = {}; // Map to store type descriptions
  Map<int, String> get titles => _titles;

  // Method to fetch anniversary types from the database

  Future<void> fetchTitles() async {
    try {
      final response = await http.get(Uri.parse(Const.titleUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var titles = ClientTitle.fromJson(item);
          _titles[titles.titleId] = titles.description;
        }

        // Notify listeners after updating the anniversary types
        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      // Handle errors, e.g., log them or show a message to the user
      print('Error fetching title: $error');
    }
  }

  // Method to get anniversary type description by ID
  String getClientTitleDescription(int? typeId) {
    return _titles[typeId] ?? 'Unknown';
  }

  Future<void> addTitle(TextEditingController descriptionController) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(Const.titleUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 201) {
        fetchTitles();
        descriptionController.clear();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error adding title: $error');
    }
  }

  Future<void> updateTitle(
    int id,
    TextEditingController descriptionController,
    void Function() clearSelectedType,
  ) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse("${Const.titleUrl}/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 200) {
        fetchTitles();
        descriptionController.clear();
        clearSelectedType();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error updating title: $error');
    }
  }

  Future<void> deleteTitle(BuildContext context, int titleId) async {
    // Update with your actual base URL

    try {
      final response = await http.delete(
        Uri.parse('${Const.titleUrl}/$titleId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await titles.remove(titleId);
        notifyListeners();
        Navigator.pop(context);

        print('title deleted successfully');
      } else {
        // Handle the error response
        throw Exception('Failed to title: ${response.body}');
      }
    } catch (error) {
      print('Error deleting title: $error');
      // Handle exceptions here
    }
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
      print("selectedClients ${selectedClients.length.toString()}");
      // Iterate over the selected clients
      for (var client in selectedClients) {
        // Await the deletion of the client
        deleteClient(context, client);
        // Fetch the associated client extra
        ClientExtra? clientExtra =
            Provider.of<ClientExtraProvider>(context, listen: false)
                .clientsExtraMap[client.clientNo];
        // If a client extra exists, await its deletion
        if (clientExtra != null) {
          deleteClientExtra(context, clientExtra.id!);
        }
      }

      // Notify listeners after all deletions are completed
      notifyListeners();
    } catch (error) {
      print('Error deleting selected clients and their extras: $error');
    }
  }

  Future<void> deleteClientExtra(BuildContext context, String id) async {
    try {
      print("started deleting extras $id");
      final response = await http.delete(Uri.parse('${Const.clientExtraUrl}/$id'));
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
               _age=null;
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
            {"response": response.body +  "\n REspondata" + responseExtra.body});
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }finally{
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
      final response = await http.delete(Uri.parse('${Const.clientUrl}/${client.id}'));
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
