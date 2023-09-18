import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/view_member/index.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';
import 'data.dart';

class MemberListWidget extends StatelessWidget {
  final Member member;
  final User user;
  final PostgreSQLConnection connection;
  final InfoItem selectedGroup;
  final bool isAdmin;

  const MemberListWidget({
    Key? key,
    required this.member,
    required this.user,
    required this.connection,
    required this.selectedGroup,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      builder: (context, snapshot) {
        if (isAdmin) {
          return _buildMemberManagement(
              context, member, selectedGroup, connection, user);
        } else {
          return _buildMemberList(
              context, member, selectedGroup, connection, user, isAdmin);
        }
      },
    );
  }

  Widget _buildMemberManagement(
    BuildContext context,
    Member member,
    InfoItem selectedGroup,
    PostgreSQLConnection connection,
    User user,
  ) {
    bool isCreator = member.memberRole == "creator";
    bool isMemberAdmin = member.memberRole == "admin";
    bool isUserSelf = user.userId == member.memberId;

    return GestureDetector(
      onTap: () {
        // Handle tap action
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                try {
                  return Container(
                    width: 70,
                    height: 70,
                    child: Image.memory(
                      member.memberAvatar!,
                      fit: BoxFit.cover,
                    ),
                  );
                } catch (e) {
                  print("Error loading image from memory: $e");
                  return Container(
                    width: 70,
                    height: 70,
                    child: Image.network(
                      "https://tva1.sinaimg.cn/large/008i3skNgy1gsuhtensa6j30lk0li76f.jpg",
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.memberName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      member.memberRole,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Visibility(
                      visible: !isCreator && !isUserSelf,
                      child: Wrap(spacing: 8, children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () async {
                            if (await kickMember(member.memberId,
                                selectedGroup.id, connection)) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Kick Member'),
                                    content: Text(
                                        'You have kicked ' + member.memberName),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewMember(
                                                user: user,
                                                connection: connection,
                                                selectedGroup: selectedGroup,
                                                isAdmin: isAdmin,
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
                          },
                          child: Text('Kick'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: !isMemberAdmin && !isUserSelf
                              ? () async {
                                  if (await asignAdmin(member.memberId,
                                      selectedGroup.id, connection, "admin")) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Assign Admin'),
                                          content: Text('You have assigned ' +
                                              member.memberName +
                                              ' as admin'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewMember(
                                                      user: user,
                                                      connection: connection,
                                                      selectedGroup:
                                                          selectedGroup,
                                                      isAdmin: isAdmin,
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
                              : null,
                          child: Text("Asign admin"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow, // Background color
                          ),
                          onPressed: isMemberAdmin
                              ? () async {
                                  if (await asignNormalUser(member.memberId,
                                      selectedGroup.id, connection, "normal")) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Asign Normsal'),
                                          content: Text('You have Asign' +
                                              member.memberName +
                                              "As Normal User"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);

                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewMember(
                                                              user: user,
                                                              connection:
                                                                  connection,
                                                              selectedGroup:
                                                                  selectedGroup,
                                                              isAdmin: isAdmin,
                                                            )));
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              : null,
                          child: Text("Asign To Normal User"),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMemberList(
    BuildContext context,
    Member member,
    InfoItem selectedGroup,
    PostgreSQLConnection connection,
    User user,
    bool isAdmin) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              try {
                return Container(
                  width: 70,
                  height: 70,
                  child: Image.memory(
                    member.memberAvatar!,
                    fit: BoxFit.cover,
                  ),
                );
              } catch (e) {
                print("Error loading image from memory: $e");
                return Container(
                  width: 70,
                  height: 70,
                  child: Image.network(
                    "https://tva1.sinaimg.cn/large/008i3skNgy1gsuhtensa6j30lk0li76f.jpg",
                    fit: BoxFit.cover,
                  ),
                );
              }
            },
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.memberName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  member.memberRole,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
