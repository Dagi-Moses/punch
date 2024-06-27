import 'package:flutter/material.dart';

import 'package:punch/admin/screens/home/home_screen.dart';

import 'package:punch/providers/authProvider.dart';
import 'package:punch/screens/loginPage.dart';
import 'package:punch/screens/userHome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(MyApp(
    preferences: preferences,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;


  const MyApp({Key? key, required this.preferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AuthProvider(preferences: preferences),
        child: MaterialApp(
          title: 'Punch Anniversary',
          theme: ThemeData(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
           useMaterial3: true,
            textTheme: Theme.of(context).textTheme.apply(
            //    textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme)
            // .apply(bodyColor: Colors.white),
            
                // Note: The below line is required due to a current bug in Flutter:
              // https://github.com/flutter/flutter/issues/129553,
                decorationColor: Colors.blue),
                primaryColorLight: Colors.white,
                primaryColorDark: Colors.white,
            inputDecorationTheme: const InputDecorationTheme(
              prefixIconColor: Colors.black54,
              suffixIconColor: Colors.black54,
              iconColor: Colors.black54,
              labelStyle: TextStyle(color: Colors.black54),
              hintStyle: TextStyle(color: Colors.black54),
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/admin',
          routes: {
            '/login': (BuildContext context) => const LoginScreen(),
            '/forgotPass': (BuildContext context) =>
                const ForgotPasswordScreen(),
            '/admin': (context) => AdminHome(),
            //  '/library': (context) => LibraryScreen(),
            '/user': (context) => UserHome(),
          },
        ));
  }
}


        // appBarTheme: AppBarTheme(backgroundColor: bgColor, elevation: 0),
        // scaffoldBackgroundColor: bgColor,
        // primaryColor: greenColor,
        // dialogBackgroundColor: secondaryColor,
        // buttonColor: greenColor,
        // textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme)
        //     .apply(bodyColor: Colors.white),
        // canvasColor: secondaryColor,
     