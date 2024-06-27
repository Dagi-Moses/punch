// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/constants/enums/constants.dart';
import 'package:punch/models/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: checkToken(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Container(); // Replace with your UI logic
              }
            }
          },
        ),
      ),
    );
  }

 Future<bool> checkToken(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString('token');

  if (token != null) {
    // Make an HTTP GET request to validate the token
    String apiUrl = '$baseUrl/validate-token'; // Replace with your API endpoint
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        // Token is valid
        // Parse the response JSON or handle it according to your API's response
        bool tokenIsValid = true; // Example: assuming token is valid

        if (tokenIsValid) {
          // Set user provider based on token
          String role = 'admin'; // Replace with actual role received from backend
          User user = User(username: 'example', role: role, password: '');

          Provider.of<AuthProvider>(context, listen: false).setUser(user);

          // Navigate based on user role
          switch (role) {
            case 'admin':
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case 'library':
              Navigator.pushReplacementNamed(context, '/library');
              break;
            case 'user':
              Navigator.pushReplacementNamed(context, '/user');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
          return true;
        } else {
          return false;
        }
      } else {
        // Token validation failed or other API error
        // Handle error scenario, e.g., token expired, unauthorized
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      }
    } catch (e) {
      // Exception handling for network errors
      print('Error validating token: $e');
      Navigator.pushReplacementNamed(context, '/login');
      return false;
    }
  } else {
    // No token found in SharedPreferences
    Navigator.pushReplacementNamed(context, '/login');
    return false;
  }
}








// class LibraryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Library Dashboard')),
//       body: Center(child: Text('Library Screen')),
//     );
//   }
// }

}