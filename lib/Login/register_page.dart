import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'package:postgres/postgres.dart';
import 'dart:typed_data';

class RegisterPage extends StatefulWidget {
  final PostgreSQLConnection connection;

  const RegisterPage({Key? key, required this.connection}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username,
      _password,
      _email,
      _contactNumber,
      _emergencyContactNumber,
      _passportNumber;

  File? _avatarImage;

  Uint8List? previewAvatarImage = null;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _avatarImage = File(pickedImage.path);
      final bytes = await _avatarImage!.readAsBytes();
      setState(() {
        previewAvatarImage = bytes;
      });
    }
  }

  void saveUserToDatabase() async {
    String? avatarData;
    if (_avatarImage != null) {
      // Convert the image to base64 or save it to a file
      final bytes = await _avatarImage!.readAsBytes();
      avatarData = base64Encode(bytes);
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Check if a user with the same username already exists
        var existingUsers = await widget.connection.query(
          "SELECT user_name FROM \"user\" WHERE user_name = @username",
          substitutionValues: {"username": _username},
        );
        if (existingUsers.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Username $_username already exists")),
          );
        } else {
          // Insert the new user
          await widget.connection.query(
            "INSERT INTO \"user\" (user_name, user_password, user_ic, email_address, living_address, phone_no, emergency_call, balance, avatar) VALUES (@username, @password, @passportNumber, @email, @living, @contactNumber, @emergencyContactNumber, @balance, @avatar)",
            substitutionValues: {
              "username": _username,
              "password": _password,
              "passportNumber": _passportNumber,
              "email": _email,
              "living": "Malaysia",
              "contactNumber": _contactNumber,
              "emergencyContactNumber": _emergencyContactNumber,
              "balance": 0,
              "avatar": avatarData,
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User $_username registered successfully")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Username"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a username";
                        }
                        return null;
                      },
                      onSaved: (value) => _username = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Password"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a password";
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                      obscureText: true,
                    ),
                    // TextFormField(
                    //   decoration: InputDecoration(labelText: "Confirm Password"),
                    //   validator: (value) {
                    //     if (value != _password) {
                    //       return "Passwords do not match";
                    //     }
                    //     return null;
                    //   },
                    //   onSaved: (value) => _confirmPassword = value!,
                    //   obscureText: true,
                    // ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (!value!.contains("@")) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Contact Number"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a contact number";
                        }
                        return null;
                      },
                      onSaved: (value) => _contactNumber = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Emergency Contact Number"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter an emergency contact number";
                        }
                        return null;
                      },
                      onSaved: (value) => _emergencyContactNumber = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Passport Number"),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a passport or ic number";
                        }
                        return null;
                      },
                      onSaved: (value) => _passportNumber = value!,
                    ),

                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Avatar Image'),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 10),
                        if (previewAvatarImage != null)
                          Image.memory(
                            previewAvatarImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        saveUserToDatabase();
                      },
                      child: Text('Register'),
                    )
                  ]))),
        ));
  }
}
