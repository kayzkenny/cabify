import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cabify/providers/auth_provider.dart';

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> signOut() async {
      await context.read(authServiceProvider).signOut();
      // Navigator.pushReplacementNamed(context, '/');
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Cabify",
          style: TextStyle(color: Colors.black, fontSize: 32.0),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Center(
          child: FlatButton(
            onPressed: signOut,
            child: Text('Log Out'),
          ),
        ),
      ),
    );
  }
}
