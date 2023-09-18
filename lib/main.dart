import 'dart:core';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'Login/login_page.dart';
import 'Login/register_page.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  // Initialize the connectivity plugin
  WidgetsFlutterBinding.ensureInitialized();
  // Start the background service

  Connectivity().checkConnectivity();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PostgreSQLConnection _connection;

  @override
  void initState() {
    super.initState();

    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    _connection = PostgreSQLConnection(
      '10.112.53.35',
      // '192.168.100.17',
      5432,
      'postgres',
      username: 'postgres',
      password: '1234',
    );
    await _connection.open();
    print('Connected to the database');
  }

  @override
  void dispose() {
    _connection.close();
    print('Connection closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hikers Family',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(
              onClickedSignUp: () {
                Navigator.pushNamed(context, '/register');
              },
              connection: _connection,
            ),
        '/register': (context) => RegisterPage(connection: _connection),

        // '/attendance': (context) => Attendance(connection: _connection),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
