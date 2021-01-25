import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cabify/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cabify/widgets/error_dialog.dart';
import 'package:cabify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool loading = false;
  bool passwordHidden = true;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {
    void togglePasswordVisibility() =>
        setState(() => passwordHidden = !passwordHidden);

    Future<void> createUserWithEmailAndPassword() async {
      try {
        setState(() => loading = true);
        final user = await context
            .read(authServiceProvider)
            .createUserWithEmailAndPassword(
              emailController.text,
              passwordController.text,
            );
        setState(() => loading = false);

        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        showErrorDialog(
          context: context,
          title: "Error on Sign Up",
          content: e.message,
        );
      } on PlatformException catch (e) {
        showErrorDialog(
          context: context,
          title: "Error on Sign Up",
          content: e.message,
        );
      } on SocketException catch (e) {
        showErrorDialog(
          context: context,
          title: "Request Timed Out",
          content: e.message,
        );
      } catch (e) {
        showErrorDialog(
          context: context,
          title: "Something went wrong",
          content: "Please try again later",
        );
      } finally {
        setState(() => loading = false);
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextFormField(
                  decoration: kFormInputDecoration.copyWith(
                    labelText: 'Email',
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  cursorColor: Colors.black12,
                  validator: (value) => value.isEmpty ? 'Enter an email' : null,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.0),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      decoration: kFormInputDecoration.copyWith(
                        labelText: 'Password',
                        hintText: '********',
                      ),
                      obscureText: passwordHidden,
                      validator: (value) =>
                          value.isEmpty ? 'Enter an email' : null,
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Colors.black12,
                    ),
                    passwordHidden
                        ? IconButton(
                            icon: Icon(Icons.visibility_off),
                            color: Colors.grey,
                            onPressed: () {
                              togglePasswordVisibility();
                            },
                          )
                        : IconButton(
                            icon: Icon(Icons.visibility),
                            color: Colors.grey,
                            onPressed: () {
                              togglePasswordVisibility();
                            },
                          ),
                  ],
                ),
                SizedBox(height: 16.0),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      decoration: kFormInputDecoration.copyWith(
                        labelText: 'Confirm Password',
                        hintText: '********',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter an email';
                        }

                        if (value != passwordController.value.text) {
                          return 'Passwords don\'t match';
                        }

                        return null;
                      },
                      controller: confirmPasswordController,
                      obscureText: passwordHidden,
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Colors.black12,
                    ),
                    passwordHidden
                        ? IconButton(
                            icon: Icon(Icons.visibility_off),
                            color: Colors.grey,
                            onPressed: () {
                              togglePasswordVisibility();
                            },
                          )
                        : IconButton(
                            icon: Icon(Icons.visibility),
                            color: Colors.grey,
                            onPressed: () {
                              togglePasswordVisibility();
                            },
                          ),
                  ],
                ),
                SizedBox(height: 32.0),
                SizedBox(
                  height: 64.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        createUserWithEmailAndPassword();
                      }
                    },
                    child: loading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : Text("Sign Up"),
                    elevation: 2.0,
                    color: Colors.black,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 64.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text("Already have an account? Log In"),
                    elevation: 2.0,
                    color: Colors.greenAccent,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
