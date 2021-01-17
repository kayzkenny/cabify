import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    Key key,
    @required this.error,
    @required this.stack,
  }) : super(key: key);

  final Object error;
  final StackTrace stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('${error.toString()}'),
        ),
      ),
    );
  }
}
