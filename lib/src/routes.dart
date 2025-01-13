import 'package:flutter/material.dart';
import 'package:punch/admin/screens/home/home_screen.dart';
import 'package:punch/screens/libraryScreen.dart';
import 'package:punch/screens/loginPage.dart';
import 'package:punch/screens/userHome.dart';


class Routes {
  static const String login = '/login';
  static const String forgotPassword = '/forgotPass';
  static const String admin = '/admin';
  static const String user = '/user';
  static const String library = '/library';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => AdminHome());
      case user:
        return MaterialPageRoute(builder: (_) =>  UserHome());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
