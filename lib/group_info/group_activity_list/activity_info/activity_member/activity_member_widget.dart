import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/group_activity_list/activity_info/activity_member/index.dart';
import 'package:hiking_platform/group_info/view_member/index.dart';
import 'package:postgres/postgres.dart';

import '../../../../query.dart';

import 'data.dart';

class ActivityMemberListWidget extends StatelessWidget {
  final ActivityMemberClass activityMember;
  final User user;
  final PostgreSQLConnection connection;
  final InfoItem selectedGroup;
  final int selectedActivityId;
  final bool isOrganiser;

  const ActivityMemberListWidget({
    Key? key,
    required this.activityMember,
    required this.user,
    required this.connection,
    required this.selectedActivityId,
    required this.selectedGroup,
    required this.isOrganiser,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      builder: (context, snapshot) {
        if (isOrganiser || activityMember.memberRole == 'guide') {
          return _buildMemberManagement(
              context, activityMember, selectedGroup, connection, user);
        } else {
          return _buildMemberList(context, activityMember, selectedGroup,
              connection, user, isOrganiser);
        }
      },
    );
  }

  Widget _buildMemberManagement(
    BuildContext context,
    ActivityMemberClass activityMember,
    InfoItem selectedGroup,
    PostgreSQLConnection connection,
    User user,
  ) {
    bool isUserSelf = user.userId == activityMember.memberId;
    bool isGuide = activityMember.memberRole == "guide";
    bool isPaid = activityMember.isPaid == true;

    return GestureDetector(
      onTap: () {
        // Handle onTap event
      },
      child: Container(
        height: 120,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                try {
                  return Container(
                    width: 70,
                    height: 70,
                    child: Image.memory(
                      activityMember.avatarUrl!,
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
                      activityMember.memberName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      activityMember.memberRole,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      isPaid ? 'Paid' : 'Haven\'t made payment',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    activityMember.isCheckin
                        ? Text(
                            activityMember.isCheckout
                                ? 'Already Checked Out'
                                : 'Haven\'t checked out',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          )
                        : Text(
                            'Absent',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                    GestureDetector(
                      onLongPress: () {
                        final latLongText = activityMember.location;
                        Clipboard.setData(ClipboardData(text: latLongText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied: $latLongText')),
                        );
                      },
                      child: Text(
                        "Location:" + activityMember.location,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Visibility(
                      visible: !isUserSelf && isOrganiser,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                minimumSize: Size(100, 30),
                              ),
                              onPressed: () async {
                                if (await kickActivityMember(
                                  activityMember.memberId,
                                  selectedActivityId,
                                  connection,
                                )) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Kick Member'),
                                        content: Text('You have kicked ' +
                                            activityMember.memberName),
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
                                                    isAdmin: isOrganiser,
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
                              child: Text("Kick"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.yellow,
                                minimumSize: Size(180, 30),
                              ),
                              onPressed: !isGuide && !isUserSelf
                                  ? () async {
                                      if (await asignActivityGuide(
                                        activityMember.memberId,
                                        selectedActivityId,
                                        connection,
                                        "guide",
                                      )) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Assign Guide'),
                                              content: Text(
                                                  'You have assigned ' +
                                                      activityMember
                                                          .memberName +
                                                      ' as a guide.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ActivityMemberPage(
                                                          user: user,
                                                          connection:
                                                              connection,
                                                          selectedGroup:
                                                              selectedGroup,
                                                          isOrganiser:
                                                              isOrganiser,
                                                          selectedActivityId:
                                                              selectedActivityId,
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
                              child: Text("Assign Guide"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.yellow,
                                minimumSize: Size(200, 30),
                              ),
                              onPressed: isGuide
                                  ? () async {
                                      if (await asignActivityNormalUser(
                                        activityMember.memberId,
                                        selectedActivityId,
                                        connection,
                                        "member",
                                      )) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  Text('Assign Normal Hiker'),
                                              content: Text(
                                                  'You have assigned ' +
                                                      activityMember
                                                          .memberName +
                                                      ' as a normal user.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ActivityMemberPage(
                                                          user: user,
                                                          connection:
                                                              connection,
                                                          selectedGroup:
                                                              selectedGroup,
                                                          isOrganiser:
                                                              isOrganiser,
                                                          selectedActivityId:
                                                              selectedActivityId,
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
                              child: Text("Assign to Normal Hiker"),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildMemberList(
      BuildContext context,
      ActivityMemberClass member,
      InfoItem selectedGroup,
      PostgreSQLConnection connection,
      User user,
      bool isOrganiser) {
    return GestureDetector(
      onTap: () {
        // // print(data.title)
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => JoinGroupPage(
        //             group: data,
        //             connection: connection,
        //             user: user,
        //           )),
        // );
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
                      activityMember.avatarUrl!,
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
}
