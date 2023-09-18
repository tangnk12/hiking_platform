import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import 'data.dart';

class ForgetPasswordPage extends StatefulWidget {
  final PostgreSQLConnection connection;

  const ForgetPasswordPage({Key? key, required this.connection})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ForgetPasswordState();
  }
}

class ForgetPasswordState extends State<ForgetPasswordPage> {
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  late String verificationCode;
  late String changePassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        backgroundColor: Colors.green,
        title: Text("Forget Password"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Please Type In Your Account Username',
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Please Type In Your Account Email',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: Text(
                "Send Verify Code",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                int sendResult = await validateEmail(
                  widget.connection,
                  usernameController.text,
                  emailController.text,
                );
                if (sendResult == 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Send Code Result'),
                        content: Text("Account doesn't exist"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (sendResult == 3) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Send Code Result'),
                        content: Text("Failed to send verification code"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (sendResult == 2) {
                  // Close the previous dialog
                  await _showVerificationColumn(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVerificationColumn(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Verification Code'),
          content: TextField(
            onChanged: (value) {
              verificationCode = value;
            },
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the current dialog

                bool verifyResult = await verifyCode(
                  usernameController.text,
                  verificationCode,
                  widget.connection,
                );

                if (verifyResult) {
                  await _showChangePasswordDialog(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Verification Failed'),
                        content: Text('Invalid verification code.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    String username = usernameController.text;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Your Password'),
          content: TextField(
            onChanged: (value) {
              changePassword = value;
            },
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Change Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool success = await requestChangePassword(
                  username,
                  changePassword,
                  widget.connection,
                );

                if (success) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Password Changed'),
                        content: Text(
                            'Your password has been changed successfully.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.popUntil(
                                  context, ModalRoute.withName('/'));
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Password Change Failed'),
                        content: Text('Failed to change the password.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
