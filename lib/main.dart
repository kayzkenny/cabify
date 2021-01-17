import 'package:flutter/material.dart';
import 'package:cabify/pages/unknown_page.dart';
import 'package:cabify/pages/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cabify/pages/authenticate/login_page.dart';
import 'package:cabify/pages/authenticate/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cabify',
      theme: ThemeData(
        primaryColor: Colors.greenAccent,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => LandingPage(),
          );
        }

        if (settings.name == '/signup') {
          return MaterialPageRoute(
            builder: (context) => SignUpPage(),
          );
        }

        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => LoginPage(),
          );
        }

        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
    );
  }
}
