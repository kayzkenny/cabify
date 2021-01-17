import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 32.0),
              Icon(
                Icons.car_rental,
                size: 100.0,
              ),
              SizedBox(height: 64.0),
              Text(
                "Welcome.",
                style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.black45,
                ),
              ),
              Text(
                "Modern travel",
                style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.black45,
                ),
              ),
              Text(
                "Starts here",
                style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.black45,
                ),
              ),
              SizedBox(height: 64.0),
              Text(
                "Setting 700+ cities in motion",
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black45,
                ),
              ),
              SizedBox(height: 64.0),
              SizedBox(
                height: 64.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text("Log in"),
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
    );
  }
}
