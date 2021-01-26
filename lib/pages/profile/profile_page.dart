import 'package:cabify/models/user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/providers/database_provider.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final userDataStream = watch(userDataProvider);

    return userDataStream.when(
      data: (userData) => ProfileForm(userData: userData),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Something went wrong'),
        ),
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  ProfileForm({this.userData, Key key}) : super(key: key);

  final UserData userData;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final snackBar = SnackBar(
    content: Text('Profile Updated'),
    backgroundColor: Colors.brown[700],
  );
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool loading = false;
  String username = "";
  String phoneNumber = "";

  Future<void> updateUserData(UserData userData) async {
    await context.read(databaseProvider).updateUserData(userData: userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headline5,
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    hintText: 'User Name',
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) => value.isEmpty ? 'User Name' : null,
                  onChanged: (value) => setState(() => username = value),
                  initialValue: widget.userData?.username ?? "",
                ),
                SizedBox(height: 32.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) => value.isEmpty ? 'Phone Number' : null,
                  onChanged: (value) => setState(() => phoneNumber = value),
                  initialValue: widget.userData?.phoneNumber ?? "",
                ),
                SizedBox(height: 48.0),
                SizedBox(
                  height: 64.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        UserData _formUserData = UserData(
                          username: username,
                          phoneNumber: phoneNumber,
                        );
                        updateUserData(_formUserData);
                        // _scaffoldKey.currentState.showSnackBar(snackBar);
                        print('-----------------------');
                        print(username);
                      }
                    },
                    child: Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.white),
                    ),
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
