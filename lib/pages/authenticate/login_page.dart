import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cabify/shared/constants.dart';
import 'package:cabify/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cabify/providers/auth_provider.dart';

class LoginPage extends HookWidget {
  LoginPage({Key key}) : super(key: key);

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final passwordHidden = useState(true);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    void togglePasswordVisibility() =>
        passwordHidden.value = !passwordHidden.value;

    Future<void> signInWithEmailAndPassword() async {
      try {
        loading.value = true;
        final user =
            await context.read(authServiceProvider).signInWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
        loading.value = false;

        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        showErrorDialog(
          context: context,
          title: "Error on Log In",
          content: e.message,
        );
      } on PlatformException catch (e) {
        showErrorDialog(
          context: context,
          title: "Error on Log In",
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
        loading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Log In",
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
                      obscureText: passwordHidden.value,
                      validator: (value) =>
                          value.isEmpty ? 'Enter an email' : null,
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Colors.black12,
                    ),
                    passwordHidden.value
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
                        signInWithEmailAndPassword();
                      }
                    },
                    child: loading.value
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : Text("Login"),
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
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: Text("Don\'t have an account? Sign Up"),
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
