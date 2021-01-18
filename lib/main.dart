import 'package:flutter/material.dart';
import 'package:cabify/pages/error_page.dart';
import 'package:cabify/pages/auth_wrapper.dart';
import 'package:cabify/pages/loading_page.dart';
import 'package:cabify/pages/unknown_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cabify/pages/home/home_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cabify/providers/app_provider.dart';
import 'package:cabify/pages/authenticate/login_page.dart';
import 'package:cabify/pages/authenticate/signup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: App()));
}

class App extends HookWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final _firebaseApp = useProvider(firebaseAppProvider);

    return _firebaseApp.when(
      data: (firebaseApp) => MaterialApp(
        title: 'Cabify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.greenAccent,
          textTheme: GoogleFonts.latoTextTheme(textTheme),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (context) => AuthWrapper());
          }

          if (settings.name == '/signup') {
            return MaterialPageRoute(builder: (context) => SignUpPage());
          }

          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (context) => LoginPage());
          }

          if (settings.name == '/home') {
            return MaterialPageRoute(builder: (context) => HomePage());
          }

          return MaterialPageRoute(builder: (context) => UnknownPage());
        },
      ),
      loading: () => LoadingPage(),
      error: (error, stack) => ErrorPage(error: error, stack: stack),
    );
  }
}
