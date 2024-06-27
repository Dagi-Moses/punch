import 'package:flutter/material.dart';
import 'package:punch/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  SharedPreferences preferences;
  final String baseUrl = 'http://localhost:3000';
  User? _user;

  AuthProvider({required this.preferences});

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
