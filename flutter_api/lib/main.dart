import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SingupSection(),
      routes: {
        LandingScreen.id: (context) => LandingScreen(),
        LoginSection.id: (context) => LoginSection()
      },
    );
  }
}

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class SingupSection extends StatelessWidget {
  var _email;
  var _password;

  @override
  Widget build(BuildContext context) {
    checkToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      if (token != null) {
        Navigator.pushNamed(context, LandingScreen.id);
      }
    }

    checkToken();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                clearButtonMode: OverlayVisibilityMode.editing,
                autocorrect: false,
                onChanged: (email) => {_email = email},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                  placeholder: 'Password',
                  clearButtonMode: OverlayVisibilityMode.editing,
                  obscureText: true,
                  autocorrect: false,
                  onChanged: (password) => {_password = password}),
            ),
            FlatButton.icon(
                onPressed: () async {
                  await signup(_email, _password);

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String token = prefs.getString("token");
                  if (token != null) {
                    Navigator.pushNamed(context, LandingScreen.id);
                  }
                },
                icon: Icon(Icons.save),
                label: Text('Sign up')),
            FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, LoginSection.id);
                },
                child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

signup(email, password) async {
  var url = 'http://10.0.2.2:5000/signup';

  final http.Response response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email, 'password': password}),
  );
  print(response.body);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //parse json data
  var parse = jsonDecode(response.body);

  await prefs.setString('token', parse['token']);
}

class LoginSection extends StatelessWidget {
  static const String id = "LoginSection";

  var _email;
  var _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CupertinoTextField(
                  placeholder: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autocorrect: false,
                  onChanged: (email) => {_email = email},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CupertinoTextField(
                    placeholder: 'Password',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    obscureText: true,
                    autocorrect: false,
                    onChanged: (password) => {_password = password}),
              ),
              FlatButton.icon(
                  onPressed: () async {
                    await login(_email, _password);

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String token = prefs.getString("token");
                    if (token != null) {
                      Navigator.pushNamed(context, LandingScreen.id);
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}

login(email, password) async {
  var url = 'http://10.0.2.2:5000/login';

  final http.Response response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email, 'password': password}),
  );
  print(response.body);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //parse json data
  var parse = jsonDecode(response.body);

  await prefs.setString('token', parse['token']);
}

class LandingScreen extends StatelessWidget {
  static const String id = "landing screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text('This is the Landing Page.')),
            FlatButton.icon(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('token', null);

                  Navigator.pushNamed(context, LoginSection.id);
                },
                icon: Icon(Icons.send),
                label: Text('Log out'))
          ],
        ));
  }
}
