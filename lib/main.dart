import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:punch/admin/screens/home/home_screen.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/auth.dart';

import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/clientExtraProvider.dart';
import 'package:punch/providers/clientProvider.dart';
import 'package:punch/providers/companyProvider.dart';
import 'package:punch/providers/dashboardPageProvider.dart';
import 'package:punch/providers/textConroller.dart';
import 'package:punch/screens/libraryScreen.dart';
import 'package:punch/screens/loginPage.dart';
import 'package:punch/screens/manageAnniversaryTypes.dart';
import 'package:punch/screens/splashScreen.dart';
import 'package:punch/screens/userHome.dart';
import 'package:paged_datatable/l10n/generated/l10n.dart';

import 'package:provider/provider.dart';
import 'package:punch/src/routes.dart';

Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardPageProvider()),
        ChangeNotifierProvider(create: (_) => AnniversaryProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ClientExtraProvider()),
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => TextControllerNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clientExtra =
        Provider.of<ClientExtraProvider>(context, listen: false);
    return ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          localizationsDelegates: const [
            PagedDataTableLocalization.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'NG'),
          ],
          title: 'Punch Anniversary',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            textTheme: kIsWeb ? GoogleFonts.robotoTextTheme() : null,
           
             floatingActionButtonTheme: FloatingActionButtonThemeData(
              hoverColor: hoverPunchRed,
              backgroundColor:  punchRed, // FAB background color
              foregroundColor: Colors.white, // FAB icon/text color
              elevation: 4, // Optional: Adjust the shadow
            ),
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
                    return AdminHome();
                  } else {
                    return const LoginScreen();
                  }
                },
              );
            },
          ),
     
          onGenerateRoute: Routes.generateRoute,
        ));
  }
}
