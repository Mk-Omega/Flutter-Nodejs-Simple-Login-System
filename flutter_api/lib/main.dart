import 'dart:convert';
import 'dart:io';

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
        LoginSection.id: (context) => LoginSection(),
        LogoutScreen.id: (context) => LogoutScreen(),
        PrivateRoute.id: (context) => PrivateRoute(),
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
        ],
      ),
      bottomNavigationBar: bottomNaviagtion(),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  static const String id = "LogoutScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text("This is the logout page")),
          FlatButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', null);

                Navigator.pushNamed(context, LoginSection.id);
              },
              icon: Icon(Icons.send),
              label: Text('Log out'))
        ],
      ),
      bottomNavigationBar: bottomNaviagtion(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class bottomNaviagtion extends StatefulWidget {
  bottomNaviagtion({Key key}) : super(key: key);

  @override
  _bottomNaviagtionState createState() => _bottomNaviagtionState();
}

/// This is the private State class that goes with bottomNaviagtion.
class _bottomNaviagtionState extends State<bottomNaviagtion> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        Navigator.pushNamed(context, LandingScreen.id);
      } else if (index == 1) {
        Navigator.pushNamed(context, PrivateRoute.id);
      } else {
        Navigator.pushNamed(context, LogoutScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Logout',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }
}

Future<Album> fetchAlbum() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token");

  final response = await http.get('http://10.0.2.2:5000/token/',
      // Send authorization headers to the backend.
      headers: {"token": token});

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String message;

  Album({this.message});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      message: json['msg'],
    );
  }
}

class PrivateRoute extends StatefulWidget {
  static const String id = "private Route";

  PrivateRoute({Key key}) : super(key: key);

  @override
  _PrivateRouteState createState() => _PrivateRouteState();
}

class _PrivateRouteState extends State<PrivateRoute> {
  Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.message);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
        bottomNavigationBar: bottomNaviagtion(),
      ),
    );
  }
}
