import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/tab_profile/userData.dart';

import 'package:postgres/postgres.dart';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../query.dart';
import '../home_page.dart';

var loginRegisterStyle = TextStyle(fontSize: 20, color: Colors.white);

class Header extends StatefulWidget {
  final PostgreSQLConnection connection;

  final User user;

  const Header({super.key, required this.connection, required this.user});
  @override
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> {
  Uint8List? avatarBytes;
  final String userImage =
      'https://tva1.sinaimg.cn/large/008i3skNgy1gsuhtensa6j30lk0li76f.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    // Fetch the updated user data from the database
    // Fetch the updated user data from the database
    User? updatedUser = await getUserData(widget.user, widget.connection);

    // Update the user data in the state
    setState(() {
      widget.user.userPhone = updatedUser!.userPhone;
      widget.user.emegencyPhone = updatedUser.emegencyPhone;
      widget.user.userEmail = updatedUser.userEmail;
      widget.user.userIc = updatedUser.userIc;
      widget.user.avatar = updatedUser.avatar;

      widget.user.balance = updatedUser.balance;
      // Assign other updated properties as well
    });
  }

  Future<void> _showTopUpDialog(BuildContext context) async {
    double topUpValue = 0;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter TopUp Amount'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                topUpValue = double.parse(value);
              });
            },
            decoration: InputDecoration(
              labelText: 'TopUp',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await topUp(widget.user.userId, topUpValue, widget.connection);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 20, bottom: 20),
      decoration: BoxDecoration(color: Colors.green),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 65,
            margin: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundImage: widget.user.avatar != null
                  ? MemoryImage(widget.user.avatar!) as ImageProvider<Object>
                  : NetworkImage(userImage),
            ),
          ),
          // User Information
          Expanded(
            child: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(padding: EdgeInsets.all(6)),
                  Text(
                    widget.user.userName,
                    style: loginRegisterStyle,
                  ),
                  // SizedBox(height: 10),
                  Text(
                    "Ic or Passport: ${widget.user.userIc}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Email: ${widget.user.userEmail}",
                    style: TextStyle(color: Colors.white),
                  ),

                  Text(
                    "Phone :+60 ${widget.user.userPhone}",
                    style: TextStyle(color: Colors.white),
                  ),

                  Text(
                    "Emergency Call:+60 ${widget.user.emegencyPhone}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          await _showTopUpDialog(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                connection: widget.connection,
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "+",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Text(
                        "Balance: " + widget.user.balance.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
