import 'package:flutter/material.dart';
import 'package:cabify/pages/landing_page.dart';
import 'package:cabify/pages/home/home_page.dart';
import 'package:cabify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  AuthWrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final authStateStream = watch(authStateProvider);
    return authStateStream.when(
      data: (value) => value == null ? LandingPage() : HomePage(),
      loading: () => Scaffold(
        body: Center(
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('${error.toString()}'),
        ),
      ),
    );
  }
}
