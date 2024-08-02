import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/myModels/userModel.dart';

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<User> signIn(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/users/signin');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else {
      throw Exception('Failed to sign in');
    }
  }
}
