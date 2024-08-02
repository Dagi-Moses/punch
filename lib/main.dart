import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:punch/admin/screens/home/home_screen.dart';
import 'package:punch/models/myModels/userModel.dart';
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
  await WidgetsFlutterBinding.ensureInitialized();

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
  Widget _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AdminHome();
      case UserRole.library:
        return LibraryScreen();
      default:
        return UserHome();
    }
  }

  Widget _navigateToLogin() {
    return LoginScreen();
  }

  const MyApp({
    Key? key,
  }) : super(key: key);

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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            textTheme: kIsWeb ? GoogleFonts.robotoTextTheme() : null,
           
          ),
          debugShowCheckedModeBanner: false,
          home: Consumer<AuthProvider?>(
            builder: (context, authProvider, _) {
              return StreamBuilder<User?>(
                stream: authProvider?.userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SplashScreen();
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return _navigateBasedOnRole(snapshot.data!.role!);
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
