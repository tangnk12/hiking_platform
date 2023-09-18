import 'package:postgres/postgres.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

String _generateVerificationCode() {
  // Generate a random 6-digit verification code
  Random random = Random();
  int code = random.nextInt(999999);
  return code.toString().padLeft(6, '0');
}

Future<bool> _sendVerificationCode(
    String email, String verificationCode) async {
  // Configure the SMTP server for sending emails
  final smtpServer = SmtpServer(
    'smtp.gmail.com',
    username: 'ningkangtang82@gmail.com',
    password: 'uzqmcvmonksmlqnw',
    port: 587,
  );

  // Create the email message
  final message = Message()
    ..from = Address('ningkangtang82@gmail.com')
    ..recipients.add(email)
    ..subject = 'Password Reset Code'
    ..text = 'Your password reset code is: $verificationCode';

  // Send the email
  try {
    final sendReport = await send(message, smtpServer);
    return true;
  } catch (e) {
    print('Error sending email: $e');
    return false;
  }
}

Future<void> _storeVerificationCodeInDatabase(String username,
    String verificationCode, PostgreSQLConnection connection) async {
  await connection.query(
      "UPDATE \"user\" SET verification_code = @verificationCode WHERE user_name = @userName",
      substitutionValues: {
        "userName": username,
        "verificationCode": verificationCode
      });
}

Future<int> validateEmail(
    PostgreSQLConnection connection, String username, String email) async {
  var results = await connection.query(
    'SELECT user_name, email_address FROM \"user\" WHERE user_name = @username AND email_address = @email',
    substitutionValues: {'username': username, 'email': email},
  );

  if (results.isEmpty) {
    return 1;
  } else {
    // Generate and send the verification code to the email address
    String verificationCode = _generateVerificationCode();
    bool sent = await _sendVerificationCode(email, verificationCode);

    if (sent) {
      // Store the verification code in the database for later verification
      await _storeVerificationCodeInDatabase(
          username, verificationCode, connection);
      // return "Verification code sent to email";
      return 2;
    } else {
      // return "Failed to send verification code";
      return 3;
    }
  }
}

Future<bool> verifyCode(String username, String verificationCode,
    PostgreSQLConnection connection) async {
  var result = await connection.query(
    'SELECT user_name FROM \"user\" WHERE user_name = @username AND verification_code = @code',
    substitutionValues: {'username': username, 'code': verificationCode},
  );

  return result.isNotEmpty;
}

Future<bool> requestChangePassword(
    String username, String password, PostgreSQLConnection connection) async {
  try {
    await connection.query(
        "UPDATE \"user\" SET user_password = @password WHERE user_name = @userName",
        substitutionValues: {
          "userName": username,
          "password": password,
        });
  } on Exception catch (e) {
    // TODO
    print(e);
    return false;
  }

  return true;
}
