import 'package:flutter/material.dart';
import 'package:cabify/pages/error_page.dart';
import 'package:cabify/pages/auth_wrapper.dart';
import 'package:cabify/pages/loading_page.dart';
import 'package:cabify/pages/unknown_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cabify/providers/app_provider.dart';
import 'package:cabify/pages/search/search_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/pages/authenticate/login_page.dart';
import 'package:cabify/pages/authenticate/signup_page.dart';
import 'package:cabify/pages/requestcab/requestcab_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final textTheme = Theme.of(context).textTheme;
    final _firebaseApp = watch(firebaseAppProvider);

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

          if (settings.name == '/search') {
            return MaterialPageRoute(builder: (context) => SearchPage());
          }

          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (context) => LoginPage());
          }

          if (settings.name == '/requestcab') {
            return MaterialPageRoute(builder: (context) => RequestCabPage());
          }

          return MaterialPageRoute(builder: (context) => UnknownPage());
        },
      ),
      loading: () => LoadingPage(),
      error: (error, stack) => ErrorPage(error: error, stack: stack),
    );
  }
}
