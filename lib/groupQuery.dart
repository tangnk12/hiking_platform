import 'dart:convert';
import 'dart:typed_data';

import 'package:postgres/postgres.dart';

class User {
  final int userId;
  final String userName;
  final String userIc;
  final String userEmail;
  final String userAddress;
  final String userPhone;
  final String emegencyPhone;
  final Uint8List? avatar;
  final double balance;

  User(
      this.userId,
      this.userEmail,
      this.userAddress,
      this.userIc,
      this.userPhone,
      this.emegencyPhone,
      this.userName,
      this.avatar,
      this.balance);
}

Future<User?> validateUser(
    PostgreSQLConnection connection, String username, String password) async {
  var results = await connection.query(
    'SELECT user_id, user_name, user_ic,email_address, living_address, phone_no, emergency_call,avatar,balance FROM "user" WHERE user_name = @username AND user_password = @password',
    substitutionValues: {'username': username, 'password': password},
  );

  if (results.isEmpty) {
    return null;
  } else {
    var userData = results.first;
    var avatar = userData[7] != null ? base64Decode(userData[7]) : null;

    var user = User(
        userData[0] as int,
        userData[3] as String,
        userData[4] as String,
        userData[2] as String,
        userData[5] as String,
        userData[6] as String,
        userData[1] as String,
        avatar,
        userData[8] as double);
    return user;
  }
}
