import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/tab_profile/profile_join_index.dart';
import 'package:hiking_platform/Home/tab_profile/setting_edit_profile/index.dart';

import 'package:hiking_platform/Home/tab_profile/tab_header.dart';
import 'package:hiking_platform/Login/login_page.dart';
import 'package:hiking_platform/Login/register_page.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';

class TabProfile extends StatefulWidget {
  final User user;
  final PostgreSQLConnection connection;

  const TabProfile({
    Key? key,
    required this.user,
    required this.connection,
  }) : super(key: key);

  @override
  _TabProfileState createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  double topUpValue = 0.00;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(
                    user: widget.user,
                    connection: widget.connection,
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Header(connection: widget.connection, user: widget.user),
            SizedBox(height: 20),
            ProfileGroup(
              user: widget.user,
              connection: widget.connection,
            ),
            SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onClickedSignUp: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(
                              connection: widget.connection,
                            ),
                          ),
                        );
                      },
                      connection: widget.connection,
                    ),
                  ),
                );
              },
              child: Text("LogOut"),
            ),
          ],
        ),
      ),
    );
  }
}
