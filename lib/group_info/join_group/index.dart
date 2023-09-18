import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/home_page.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/join_group/data.dart';
import 'package:hiking_platform/group_info/join_group/join_group_widget.dart';
import 'package:hiking_platform/query.dart';
import 'package:postgres/postgres.dart';

class JoinGroupPage extends StatelessWidget {
  final InfoItem group;
  final PostgreSQLConnection connection;
  final User user;

  const JoinGroupPage({
    Key? key,
    required this.group,
    required this.connection,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: group.groupName,
      home: Scaffold(
        appBar: AppBar(
          title: Text(group.groupName),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              JoinGroupWidget(
                title: group.groupName,
                groupImage: group.imageUrl,
              ),
              Padding(padding: EdgeInsets.all(20)),
              ElevatedButton(
                onPressed: () async {
                  if (await joinGroup(
                      user.userId, group.id, connection, false, "normal")) {
                    Navigator.pop(context);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          user: user,
                          connection: connection,
                        ),
                      ),
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Request Join Success'),
                          content: Text('Your request has been sent.'),
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
                  } else {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Already Joined'),
                          content:
                              Text('You are already a member of this group.'),
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
                child: Text('Join'),
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
