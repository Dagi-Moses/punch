import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:punch/admin/screens/home/home_screen.dart';
import 'package:punch/models/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/auth.dart';

import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/dashboardPageProvider.dart';
import 'package:punch/screens/libraryScreen.dart';
import 'package:punch/screens/loginPage.dart';
import 'package:punch/screens/splashScreen.dart';
import 'package:punch/screens/userHome.dart';
import 'package:paged_datatable/l10n/generated/l10n.dart';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardPageProvider()),
        ChangeNotifierProvider(create: (_) => AnniversaryProvider()),
        ChangeNotifierProvider(create: (_) => Auth()),
        // Add other providers here
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  

  Widget _navigateBasedOnRole(String role) {
    switch (role) {
      case 'admin':
        return AdminHome();
      case 'library':
        return LibraryScreen();
      default:
        return UserHome();
    }
  }

  Widget _navigateToLogin() {
    return LoginScreen();
  }

  const MyApp({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
            localizationsDelegates: const [
            // Add other localizationsDelegates here
            PagedDataTableLocalization.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'NG'), // Add other supported locales here
          ],
          title: 'Punch Anniversary',
          theme: ThemeData.dark().copyWith(
            appBarTheme: AppBarTheme(backgroundColor: bgColor, elevation: 0),
            scaffoldBackgroundColor: bgColor,
            primaryColor: greenColor,
            dialogBackgroundColor: secondaryColor,
            // buttonColor: greenColor,
            textTheme:
                GoogleFonts.openSansTextTheme(Theme.of(context).textTheme)
                    .apply(bodyColor: Colors.white),
            canvasColor: secondaryColor,
          ),
          
          // theme: ThemeData(
          //   primaryColor: Colors.blue,
          //   colorScheme: const ColorScheme.light(primary: Colors.blue),
          //  useMaterial3: true,
          // textTheme: Theme.of(context).textTheme.apply(
          //     // Note: The below line is required due to a current bug in Flutter:
          //   // https://github.com/flutter/flutter/issues/129553,
          //     decorationColor: Colors.blue),
          // inputDecorationTheme: const InputDecorationTheme(
          //   prefixIconColor: Colors.black54,
          //   suffixIconColor: Colors.black54,
          //   iconColor: Colors.black54,
          //   labelStyle: TextStyle(color: Colors.black54),
          //   hintStyle: TextStyle(color: Colors.black54),
          // ),

          // ),
          debugShowCheckedModeBanner: false,
          // initialRoute: '/admin',
          home: Consumer<AuthProvider?>(
            builder: (context, authProvider, _) {
              return StreamBuilder<User?>(
                stream: authProvider?.userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SplashScreen();
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return _navigateBasedOnRole(snapshot.data!.role);
                  } else {
                    return const LoginScreen();
                  }
                },
              );
            },
          ),
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
