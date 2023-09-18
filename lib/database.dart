import 'dart:async';
import 'package:postgres/postgres.dart';

Future<void> main() async {
  final conn = PostgreSQLConnection(
    'localhost', // Host
    5432, // Port
    'postgres', // Database
    username: 'postgres', // Username
    password: 'pokemoN12@!', // Password
  );

  await conn.open();
  print('Connected to the database');

  // Perform database operations here

  await conn.close();
  print('Connection closed');
}
