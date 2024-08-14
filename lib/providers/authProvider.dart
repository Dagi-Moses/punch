import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/models/myModels/userRecordModel.dart';
import 'package:punch/models/myModels/userWithRecord.dart';
import 'package:punch/models/myModels/web_socket_manager.dart';
import 'package:punch/providers/auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:punch/widgets/showToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000';
  final String userUrl = 'http://localhost:3000/users';
  final String userRecordUrl = 'http://localhost:3000/userRecords';
  User? _user;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;
  bool _isRowsSelected = false; // Default value
  bool get isRowsSelected => _isRowsSelected;

  late WebSocketManager _webSocketManager;
  final String webSocketUrl = 'ws://localhost:3000?channel=auth';

  setBoolValue(bool newValue) {
    _isRowsSelected = newValue;
    notifyListeners();
  }

  List<User> _users = [];
  late WebSocketChannel channel;
  List<User> get users => _users;
  List<UserRecord> _userRecords = [];
  List<UserRecord> get userRecords => _userRecords;
  List<UserWithRecord> _mergedUsersWithRecords = [];
  List<UserWithRecord> get mergedUsersWithRecords => _mergedUsersWithRecords;
  List<User> getSortedUsersByLoginDate() {
    Map<String, DateTime?> latestLoginMap = {};
    // Build a map of userId to the latest loginDateTime
    for (var record in userRecords) {
      if (record.recordId != null) {
        final userId = record.recordId.toString();
        final loginDateTime = record.loginDateTime;

        if (loginDateTime != null) {
          if (latestLoginMap[userId] == null ||
              loginDateTime.isAfter(latestLoginMap[userId]!)) {
            latestLoginMap[userId] = loginDateTime;
          }
        }
      }
    }

    // Sort users based on the latest loginDateTime from the map
    users.sort((a, b) {
      final loginDateA =
          latestLoginMap[a.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final loginDateB =
          latestLoginMap[b.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
      return loginDateB.compareTo(loginDateA);
    });

    return users;
  }

  bool _validateEmail = false;
  bool _validatePassword = false;

  bool _textButtonLoading = false;
  bool get textButtonLoading => _textButtonLoading;

  void setTextButtonLoading(bool value) {
    if (_textButtonLoading != value) {
      _textButtonLoading = value;

      notifyListeners();
    }
  }

  bool get validateEmail => _validateEmail;
  bool get validatePassword => _validatePassword;

  void setValidationStatus(
      {required bool email, required bool password, required bool loading}) {
    _textButtonLoading = loading;
    _validateEmail = email;
    _validatePassword = password;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void setErrorMessage(String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  AuthProvider() {
    _initialize();
    channel =
        WebSocketChannel.connect(Uri.parse('ws://localhost:3000?channel=auth'));

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
        await fetchUsers();
        print('socket refreshed Users');
        notifyListeners();
        break;
      case 'UPDATE':
        final index = _users.indexWhere((a) => a.id == data['id']);
        if (index != -1) {
          _users[index] = User.fromJson(data);
          print('socket updated User');
          notifyListeners();
        }
        break;
      case 'DELETE':
        await fetchUsers();
        print('socket refreshed Users');
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  Future<void> _initialize() async {
    await Future.wait([
      _checkToken(),
      fetchUsers(),
      fetchUserRecords(), // Temporarily comment out to isolate
      setupWebSocket(),
    ]);

    _mergeUsersAndRecords();
  }

  Future<void> setupWebSocket() async {
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));

    channel.stream.listen(
      (message) {
        try {
          final decodedMessage = jsonDecode(message);
          handleWebSocketMessage(decodedMessage);
          // Fixed print statement
        } catch (e) {}
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

        fetchUsers();
        notifyListeners();
        break;
      case 'UPDATE':
        final index = _users.indexWhere((a) => a.id == data['id']);
        if (index != -1) {
          _users[index] = User.fromJson(data);
          notifyListeners();
        }
        break;
      case 'DELETE':
        // _anniversaries.removeWhere((a) => a.id == data);
        fetchUsers();
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(userUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      // Optionally rethrow or handle the error
      throw error;
    }
  }

  Future<void> fetchUserRecords() async {
    final userRecordUrl = Uri.parse('$baseUrl/userRecords');
    try {
      final response = await http.get(userRecordUrl);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _userRecords = data.map((json) => UserRecord.fromJson(json)).toList();

        showToaster(
          "User Record fetched successfully!",
          Toast.LENGTH_LONG,
          Colors.green,
        );

        notifyListeners();
      } else {
        print("error getting user Record");
        showToaster(
          "error getting user Record",
          Toast.LENGTH_LONG,
          Colors.red,
        );

        throw Exception('Failed to load User Records');
      }
    } catch (error) {
      print("error getting user Record" + error.toString());
      showToaster(
        error.toString(),
        Toast.LENGTH_LONG,
        Colors.red,
      );
      throw error;
    }
  }

  Future<void> _mergeUsersAndRecords() async {
    _mergedUsersWithRecords = _users.map((user) {
      // Attempt to find the matching user record
      final matchingRecord = _userRecords.firstWhere(
        (record) => record.recordId == user.id,
        orElse: () =>
            UserRecord(), // Return an empty UserRecord if no match is found
      );

      // Check if the matchingRecord is not empty
      if (matchingRecord.recordId != null) {
        // If a matching record was found, merge it with the user
        return UserWithRecord(userModel: user, userRecordModel: matchingRecord);
      } else {
        // If no matching record was found, just return the user with an empty UserRecord
        return UserWithRecord(userModel: user, userRecordModel: UserRecord());
      }
    }).toList();

    notifyListeners();
  }

  User? get user => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> _checkToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null) {
      _updateUserController(null);
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/validateToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token}),
    );

    if (response.statusCode != 200) {
      _updateUserController(null);
      return;
    }

    final data = json.decode(response.body);

    if (data['isValid']) {
      final userJson = data['user'];
      _user = User.fromJson(userJson);
      _updateUserController(_user);
    } else {
      _updateUserController(null);
    }
  }

  void _updateUserController(User? user) {
    _userController.add(user);
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        _user = User.fromJson(userMap);
        _userController.add(_user);
      } catch (e) {
        _user = null;
        _userController.add(null);
      }
    } else {
      _user = null;
      _userController.add(null);
    }

    notifyListeners();
  }

  Future<void> action({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    _textButtonLoading = true;

    setValidationStatus(email: true, password: true, loading: true);
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      if (formKey.currentState!.validate()) {
        await _loginResult(context: context, formKey: formKey);
      }
    } catch (e) {
      _textButtonLoading = false;
      notifyListeners();
    } finally {
      _textButtonLoading = false;
      notifyListeners();
      setValidationStatus(email: false, password: false, loading: true);
    }
  }

  Future<void> _loginResult({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    final loginFormProvider = Provider.of<Auth>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final loginUrl = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': loginFormProvider.email,
          'password': loginFormProvider.password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = User.fromJson(responseData['user']);
        final token = responseData['token'];

        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user.toJson()));
        _user = user;
        _userController.add(_user);

        // Store or update the user record
        await _storeUserRecord(_user!);

        _textButtonLoading = false;
        notifyListeners();
      } else {
        _handleLoginError(response);
        print(response);
      }
    } catch (error) {
      _handleLoginException(error);
      print(error);
    } finally {
      formKey.currentState!.reset();
      _textButtonLoading = false;
      notifyListeners();
    }
  }

  Future<void> _storeUserRecord(User user) async {
    final userRecordUrl = Uri.parse('$baseUrl/userRecords');
    final computerName = await getDeviceName();

    // Check if the recordId was correctly parsed
    if (user.id == null) {
      print('Error: null user id.');
      return;
    }

    final userRecord = UserRecord(
      recordId: user.id,
      staffNo: user.staffNo,
      loginDateTime: DateTime.now(),
      computerName: computerName,
    );

    try {
      final response = await http.post(
        userRecordUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode(userRecord.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to store user record');
      } else {
        print('User record stored successfully: ${response.body}');
      }
    } catch (error) {
      print('Error storing user record: $error');
    }
  }

  void _handleLoginError(http.Response response) {
    final responseData = jsonDecode(response.body);
    _errorMessage = 'Failed to sign in';
    _user = null;
    final errorMessage = responseData['message'] ?? 'Unknown error';
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _handleLoginException(dynamic error) {
    _errorMessage = 'An error occurred';
    _user = null;
    Fluttertoast.showToast(
      msg: 'An error occurred. Please try again later.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    _textButtonLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _user = null;
    _userController.add(null);
    notifyListeners();
  }

  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    final webInfo = await deviceInfo.webBrowserInfo;
    final appVersion = RegExp(r'5.0 \(.*?\)')
            .firstMatch(webInfo.appVersion ?? "unknown")
            ?.group(0) ??
        'Unknown';
    return '''
    Browser: ${webInfo.browserName.name}
    Platform: ${webInfo.platform}
    App Version: $appVersion
    Vendor: ${webInfo.vendor}
  ''';
  }

  Future<void> addTestUser() async {
    DateTime today = DateTime.now();
    DateTime previousYear = DateTime(today.year - 1, today.month, today.day);
    var random = Random();
    int randomNumber = random.nextInt(30);
    User test = User(
      firstName: "Test User",
      lastName: "Test last Name",
      password: "password",
      staffNo: 123,
      role: UserRole.user,
    );
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(test.toJson()),
      );
      if (response.statusCode == 201) {
        showToaster(
          "Anniversary added successfully!",
          Toast.LENGTH_LONG,
          Colors.green,
        );

        notifyListeners();
      } else {
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
}
