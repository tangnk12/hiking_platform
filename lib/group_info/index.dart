import 'package:flutter/material.dart';
import 'package:hiking_platform/group_info/create_activity/index.dart';
import 'package:hiking_platform/group_info/edit_group/index.dart';
import 'package:hiking_platform/group_info/group_activity_list/index.dart';
import 'package:hiking_platform/group_info/group_info_widget.dart';
import 'package:hiking_platform/group_info/unJoinGroup.dart';
import 'package:hiking_platform/group_info/view_member/index.dart';
import 'package:hiking_platform/group_info/view_member/view_request/index.dart';
import 'package:hiking_platform/query.dart';
import 'package:postgres/postgres.dart';

import '../Home/home_page.dart';
import '../Home/search_group_list/data.dart';

class GroupInfo extends StatelessWidget {
  final PostgreSQLConnection connection;
  final InfoItem selectedGroup;
  final User user;

  //final List<InfoItem> dataList;

  GroupInfo({
    Key? key,

    // this.dataList = infoData,
    required this.connection,
    required this.user,
    required this.selectedGroup,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: verifyAdmin(user.userId, selectedGroup.id, connection),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return _buildGroupInfoWithButton(context);
        } else {
          return _buildGroupInfoWithoutButton(context);
        }
      },
    );
  }

  Widget _buildGroupInfoWithButton(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: selectedGroup.groupName,
      home: Scaffold(
        appBar: AppBar(
          title: Text(selectedGroup.groupName),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: user,
                    connection: connection,
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: Colors.white,
              onSelected: (String result) async {
                if (result == "view_members") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMember(
                        user: user,
                        connection: connection,
                        selectedGroup: selectedGroup,
                        isAdmin: true,
                      ),
                    ),
                  );
                } else if (result == "view_request") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupRequest(
                        user: user,
                        connection: connection,
                        selectedGroup: selectedGroup,
                      ),
                    ),
                  );
                } else if (result == "edit_group") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGroup(
                        currUser: user,
                        connection: connection,
                        selectedGroup: selectedGroup,
                      ),
                    ),
                  );
                } else if (result == "unjoin_group") {
                  if (await unJoinGroup(
                      user.userId, selectedGroup.id, connection)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Unjoin Group'),
                          content: Text('You have left the group.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      user: user,
                                      connection: connection,
                                    ),
                                  ),
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else if (result == "delete_group") {
                  if (await deleteGroup(
                      user.userId, selectedGroup.id, connection)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Group'),
                          content: Text('You have delete the group.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      user: user,
                                      connection: connection,
                                    ),
                                  ),
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "view_members",
                  child: ListTile(
                    leading: Icon(Icons.people),
                    title: Text('View Members'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "unjoin_group",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Unjoin Group'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "view_request",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('View Request'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "edit_group",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Edit Group'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "delete_group",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Delete Group'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              GroupInfoWidget(
                title: selectedGroup.groupName,
                groupImage: selectedGroup.imageUrl,
                groupDescription: selectedGroup.description,
              ),
              Padding(padding: EdgeInsets.all(20)),
              ActivityListInfo(
                connection: connection,
                selectedGroup: selectedGroup,
                user: user,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateActivityPage(
                  connection: connection,
                  user: user,
                  curGroup: selectedGroup,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupInfoWithoutButton(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: selectedGroup.groupName,
      home: Scaffold(
        appBar: AppBar(
          title: Text(selectedGroup.groupName),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: user,
                    connection: connection,
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String result) async {
                if (result == "view_members") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMember(
                        user: user,
                        connection: connection,
                        selectedGroup: selectedGroup,
                        isAdmin: false,
                      ),
                    ),
                  );
                } else if (result == "unjoin_group") {
                  if (await unJoinGroup(
                      user.userId, selectedGroup.id, connection)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Unjoin Group'),
                          content: Text('You have left the group.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      user: user,
                                      connection: connection,
                                    ),
                                  ),
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "view_members",
                  child: ListTile(
                    leading: Icon(Icons.people),
                    title: Text('View Members'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "unjoin_group",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Unjoin Group'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              GroupInfoWidget(
                  title: selectedGroup.groupName,
                  groupImage: selectedGroup.imageUrl,
                  groupDescription: selectedGroup.description),
              Padding(padding: EdgeInsets.all(20)),
              ActivityListInfo(
                connection: connection,
                selectedGroup: selectedGroup,
                user: user,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> verifyAdmin(
    int userId, int groupId, PostgreSQLConnection connection) async {
  var result = await connection.query(
    'SELECT user_id FROM member_list WHERE user_id = @userId AND (member_role = @adminRole OR member_role = @creatorRole) AND group_id = @groupId',
    substitutionValues: {
      'userId': userId,
      'groupId': groupId,
      'adminRole': 'admin',
      'creatorRole': 'creator'
    },
  );
  if (result.isNotEmpty) {
    return true;
  }
  return false;
}
