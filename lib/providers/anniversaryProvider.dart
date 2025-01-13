import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:punch/functions/imageFunctions.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/anniversarySector.dart';
import 'package:punch/models/myModels/anniversaryTypeModel.dart';
import 'package:punch/models/myModels/papers.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:punch/src/const.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:paged_datatable/paged_datatable.dart';

class AnniversaryProvider with ChangeNotifier {
  late WebSocketChannel channel;
  final ImagePicker _picker = ImagePicker();

  List<Anniversary> _anniversaries = [];
  List<Anniversary> get anniversaries => _anniversaries;

  List<AnniversarySector> _anniversarySectors = [];
  List<AnniversarySector> get anniversarySectors => _anniversarySectors;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  int? _anniversaryYear;
  int? get anniversaryYear => _anniversaryYear;

  bool _isAnniversaryYearEnabled = false;
  bool get isAnniversaryYearEnabled => _isAnniversaryYearEnabled;

  bool _loading = false;
  bool get loading => _loading;

  bool _updateLoading = false;
  bool get updateloading => _updateLoading;

  bool _isRowsSelected = false; 
  bool get isRowsSelected => _isRowsSelected;

  final Map<int, String> _anniversaryTypes = {}; // Map to store type descriptions
  final Map<int, String> _paperTypes = {}; // Map to store paper descriptions

  Map<int, String> get anniversaryTypes => _anniversaryTypes;
  Map<int, String> get paperTypes => _paperTypes;

  int? _selectedType;
  int? get selectedType => _selectedType;

  int? _selectedPaperType;
  int? get selectedPaperType => _selectedPaperType;
  
  Uint8List? _compressedImage;
  Uint8List? get compressedImage => _compressedImage;



  set compressedImage(Uint8List? newValue) {
    _compressedImage = newValue;
    notifyListeners();
  }
  Future<Uint8List?> pickImage() async {
    // Pick the image
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Read the image as bytes
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      // Compress the image
      final Uint8List? compressedImage = await compressToTargetSize(imageBytes, 500);

      if (compressedImage != null) {
     
        _compressedImage = compressedImage;
        notifyListeners();
         return compressedImage; 
      }
    }
    return null;
  }


  set selectedType(int? newValue) {
    _selectedType = newValue;
    notifyListeners(); 
  }

  set selectedPaperType(int? newValue) {
    _selectedPaperType = newValue;
    notifyListeners();
  }

  Future<void> fetchAnniversaryTypes() async {
    try {
      final response = await http.get(Uri.parse(Const.anniversaryTypeUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var anniversaryType = AnniversaryType.fromJson(item);
          _anniversaryTypes[anniversaryType.anniversaryTypeId] =
              anniversaryType.description;
        }

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
      final response = await http.get(Uri.parse(Const.paperUrl));

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
        Uri.parse(Const.anniversaryTypeUrl),
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
        Uri.parse(Const.paperUrl),
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
        Uri.parse("${Const.anniversaryTypeUrl}/$id"),
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
        Uri.parse("${Const.paperUrl}/$id"),
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
        Uri.parse('${Const.anniversaryTypeUrl}/$anniversaryTypeId'),
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
        Uri.parse('${Const.paperUrl}/$paperTypeId'),
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
    channel = WebSocketChannel.connect(Uri.parse(Const.anniversaryChannel));
    fetchAnniversaries();
    _initializeWebSocket();
    fetchAnniversaryTypes();
    fetchPaperTypes();
  }

  void _initializeWebSocket() {
    _webSocketManager = WebSocketManager(
      Const.anniversaryChannel,
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
      final response = await http.get(Uri.parse(Const.anniversaryUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _anniversaries =
            data.map((json) => Anniversary.fromJson(json)).toList();


        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error fetching anniversaries: $error');
      throw error;
    }
  }

  Future<void> fetchAnniversarySectors() async {
    try {
      final response = await http.get(Uri.parse(Const.anniversarySectorUrl));
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
        Uri.parse(Const.anniversaryUrl),
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
        _selectedPaperType = null;
        _selectedType = null;
        _compressedImage = null;
        _selectedDate = null;
        _anniversaryYear = null;
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
        _updateLoading = true;
        notifyListeners();
    try {
      final response = await http.patch(
        Uri.parse('${Const.anniversaryUrl}/${anniversary.id}'),
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
    }finally{
        _updateLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSelectedAnniversaries(
      BuildContext context, List<Anniversary> selectedAnniversaries) async {
    try {
      print("selectedClients ${selectedAnniversaries.length.toString()}");
      // Iterate over the selected clients
      for (var anniversary in selectedAnniversaries) {
        // Await the deletion of the client
        deleteAnniversary(context, anniversary);
      }

      // Notify listeners after all deletions are completed
      notifyListeners();
    } catch (error) {
      print('Error deleting selected clients and their extras: $error');
    }
  }

  Future<void> deleteAnniversary(
      BuildContext context, Anniversary anniversary) async {
    try {
      final response = await http
          .delete(Uri.parse('${Const.anniversaryUrl}/${anniversary.id}'));
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
        throw Exception('Failed to delete anniversary ${response.body}');
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

  void setDate(DateTime date) {
    _selectedDate = date;
    _anniversaryYear = DateTime.now().year - date.year;
    _isAnniversaryYearEnabled = true;
    notifyListeners();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
