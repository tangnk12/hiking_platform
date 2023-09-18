import 'package:flutter/material.dart';

import 'package:postgres/postgres.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';

import 'dart:io';

import 'dart:typed_data';

import '../../../query.dart';
import '../../home_page.dart';

class EditProfile extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User user;

  const EditProfile({Key? key, required this.connection, required this.user})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late String _password,
      _email,
      _contactNumber,
      _emergencyContactNumber,
      _passportNumber;

  File? _avatarImage;
  Uint8List? previewAvatarImage;
  bool showPassword = false;

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

  void edittProfile() async {
    String? avatarData;
    if (_avatarImage != null) {
      // Convert the image to base64 or save it to a file
      final bytes = await _avatarImage!.readAsBytes();
      avatarData = base64Encode(bytes);
    }
    if (_avatarImage == null) {
      avatarData =
          widget.user.avatar != null ? base64Encode(widget.user.avatar!) : null;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await widget.connection.query(
            "UPDATE \"user\" SET user_password = @password, user_ic = @passportNumber, email_address = @email, "
            "living_address = 'Malaysia', phone_no = @contactNumber, emergency_call = @emergencyContactNumber,avatar=@avatar "
            "WHERE user_id = @userId",
            substitutionValues: {
              "userId": widget.user.userId,
              "password": _password,
              "passportNumber": _passportNumber,
              "email": _email,
              "contactNumber": _contactNumber,
              "emergencyContactNumber": _emergencyContactNumber,
              "avatar": avatarData,
            });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("User ${widget.user.userName} updated successfully")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        print(e);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            connection: widget.connection,
            user: widget.user,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the values with activityData
    previewAvatarImage = widget.user.avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey,
                  child: Column(children: [
                    // TextFormField(
                    //   decoration: InputDecoration(labelText: "Username"),
                    //   initialValue: widget.user.userName,
                    //   validator: (value) {
                    //     if (value!.isEmpty) {
                    //       return "Please enter a username";
                    //     }
                    //     return null;
                    //   },
                    //   onSaved: (value) => _username = value!,
                    // ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      initialValue: widget.user.password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a password";
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                      obscureText:
                          !showPassword, // Toggle the visibility of the password field
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
                      initialValue: widget.user.userEmail,
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
                      initialValue: widget.user.userPhone,
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
                      initialValue: widget.user.emegencyPhone,
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
                      initialValue: widget.user.userIc,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a passport number";
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
                      onPressed: edittProfile,
                      child: Text('Update'),
                    )
                  ]))),
        ));
  }
}
