import 'package:flutter/material.dart';
import 'package:cabify/pages/landing_page.dart';
import 'package:cabify/pages/home/home_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cabify/providers/auth_provider.dart';

class AuthWrapper extends HookWidget {
  AuthWrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStateStream = useProvider(authStateProvider);
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
