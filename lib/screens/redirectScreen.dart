import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/screens/home/home_screen.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/screens/loginPage.dart';
import 'package:punch/screens/splashScreen.dart';
import 'package:punch/src/routes.dart';

class RedirectScreen extends StatelessWidget {
  const RedirectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final initialRoute = Uri.base.path;

    return StreamBuilder<User?>(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else if (snapshot.hasData && snapshot.data != null) {
        
          return AdminHome();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

