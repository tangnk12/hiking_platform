import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hiking_platform/Login/forgetPassword/index.dart';
import 'package:hiking_platform/Login/register_page.dart';
import 'package:postgres/src/connection.dart';

import '../Home/home_page.dart';
import '../query.dart';

class LoginPage extends StatefulWidget {
  final Function onClickedSignUp;
  final PostgreSQLConnection connection;

  LoginPage({required this.onClickedSignUp, required this.connection})
      : super();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Hiking Family"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: SingleChildScrollView(
          // Add SingleChildScrollView here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100),
              Image.asset(
                "lib/Home/tab_home/image_src/mountainLogo.png",
                width: 200,
                height: 100,
              ),
              SizedBox(height: 50),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Please Type In Username',
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Please Type In Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  var user = await validateUser(
                    widget.connection,
                    usernameController.text,
                    passwordController.text,
                  );
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          user: user,
                          connection: widget.connection,
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 24),
              GestureDetector(
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgetPasswordPage(
                        connection: widget.connection,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(
                            connection: widget.connection,
                          ),
                        ),
                      );
                    },
                  text: 'Didn\'t have an account? Register one',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
