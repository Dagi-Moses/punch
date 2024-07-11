import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/userModel.dart';
import 'package:punch/providers/auth.dart';
import 'package:punch/providers/loginFormProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000';
  User? _user;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;
  bool _validateEmail = false;
  bool _validatePassword = false;

  bool _textButtonLoading = false;
  bool get textButtonLoading => _textButtonLoading;
 

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
    _checkToken();
  }

  User? get user => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> _checkToken() async {
    print('started');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
            print("token ${token} ");
    if (token != null) {
      final response = await http.post(
        Uri.parse('$baseUrl/validateToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );
       print("response" + response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("token data" +data);
        if (data['isValid']) {
          _user = User.fromJson(data['user']);
          _userController.add(_user);

          notifyListeners();
        } else {
          _userController.add(null);
          notifyListeners();
        }
      } else {
        _userController.add(null);
        notifyListeners();
      }
    } else {
      _userController.add(null);
      notifyListeners();
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userJson = prefs.getString('user');

    print('Retrieved token: $token');
    print('Retrieved userJson: $userJson');

    if (token != null && userJson != null) {
      try {
        print('trying to add to stream: $_user');
        final userMap = jsonDecode(userJson);
        _user = User.fromJson(userMap);
        _userController.add(_user);
        print('User successfully decoded and added to stream: $_user');
      } catch (e) {
        print('Error decoding userJson: $e');
        _user = null;
        _userController.add(null);
      }
    } else {
      print('Token or userJson is null. Adding null to stream.');
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
      print('An error occurred: $e');
    } finally {
      _textButtonLoading = false;
      print('textButtonLoading value:' + textButtonLoading.toString());
      setValidationStatus(email: false, password: false, loading: true);
      notifyListeners();
    }


    
  }

 Future<void> _loginResult({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    final loginFormProvider = Provider.of<Auth>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('$baseUrl/login');
   
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': loginFormProvider.email,
        'password': loginFormProvider.password,
      }),
    );

    if (response.statusCode == 200) {
       print('success user '+ response.body);
    
      final responseData = jsonDecode(response.body);
     final user = User.fromJson(responseData['user']);
      final token = responseData['token'];
      _errorMessage = null;
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toJson()));
      _user = user;
      _userController.add(_user);
      print('added user ' + user.toString());
          print('token ' + token);
       _textButtonLoading = false;
      notifyListeners();
    } else {
      final responseData = jsonDecode(response.body);
      _errorMessage = 'Failed to sign in';
      _user = null;
      final errorMessage = responseData['message'] ?? 'Unknown error';
      print(errorMessage);
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
       _textButtonLoading = false;
      print('failure' + response.body);
    }
    formKey.currentState!.reset();
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
}
