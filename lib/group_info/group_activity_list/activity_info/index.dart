import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/edit_activity/index.dart';
import 'package:hiking_platform/group_info/group_activity_list/activity_info/attendence/index.dart';
import 'package:hiking_platform/group_info/index.dart';
import 'package:hiking_platform/query.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

import 'activity_member/index.dart';
import 'data.dart';

class ActivityPage extends StatefulWidget {
  final int activityId;
  final PostgreSQLConnection connection;
  final InfoItem selectedGroup;
  final User user;
  final bool haveJoin;

  const ActivityPage(
      {Key? key,
      required this.activityId,
      required this.connection,
      required this.user,
      required this.haveJoin,
      required this.selectedGroup});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late Future<ActivityInfo> activityData;
  bool isCreator = false;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    activityData = _getActivityInfo();
    judgeHavePaid(widget.activityId, widget.user.userId, widget.connection);
  }

  Future<ActivityInfo> _getActivityInfo() async {
    final activityInfo =
        await getActivityInfo(widget.connection, widget.activityId);
    if (activityInfo.organiserId == widget.user.userId) {
      setState(() {
        isCreator = true;
      });
    }
    return activityInfo;
  }

  Future<int> judgeHavePaid(
    int activityId,
    int userId,
    PostgreSQLConnection connection,
  ) async {
    var results = await connection.query(
      'SELECT activity_id, user_id, user_paid FROM activity_member WHERE user_id = @userId AND activity_id = @activityId ;',
      substitutionValues: {'userId': userId, 'activityId': activityId},
    );

    if (results.isNotEmpty) {
      setState(() {
        isPaid = results[0][2];
      });
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    bool haveJoin = widget.haveJoin;
    bool havePaid = isPaid;

    return FutureBuilder<ActivityInfo>(
      future: activityData,
      builder: (context, snapshot) {
        debugPrint(snapshot.data?.location.toString());

        if (snapshot.hasData) {
          DateTime date = DateTime.parse(snapshot.data!.date);
          String formattedDate = DateFormat('dd/MM/yyyy').format(date);

          return Scaffold(
            appBar: AppBar(
                title: Text(snapshot.data!.activityName),
                backgroundColor: Colors.green,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
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
                            builder: (context) => ActivityMemberPage(
                              user: widget.user,
                              connection: widget.connection,
                              selectedGroup: widget.selectedGroup,
                              selectedActivityId: widget.activityId,
                              isOrganiser: isCreator,
                            ),
                          ),
                        );
                      } else if (result == "mark_Attendance") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Attendance(
                                  activity: snapshot.data!,
                                  userId: widget.user.userId,
                                  connection: widget.connection,
                                  groupId: widget.selectedGroup.id)),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: "view_members",
                        child: ListTile(
                          leading: Icon(Icons.people),
                          title: Text('View Members'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: "mark_Attendance",
                        child: ListTile(
                          leading: Icon(Icons.people),
                          title: Text('Mark Attendance'),
                        ),
                      ),
                    ],
                  ),
                ]),
            body: Container(
              child: ListView(
                children: [
                  Padding(padding: EdgeInsets.all(50)),
                  Image.asset(
                    "lib/Home/tab_home/image_src/mountainLogo.png",
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(snapshot.data!.activityName),
                  Text("Time: " + formattedDate),
                  GestureDetector(
                    onLongPress: () {
                      final latLongText = snapshot.data!.latLong;
                      Clipboard.setData(ClipboardData(text: latLongText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied: $latLongText')),
                      );
                    },
                    child: Text(
                      "Location: " +
                          snapshot.data!.location.toString() +
                          "(" +
                          snapshot.data!.latLong +
                          ")",
                    ),
                  ),
                  Text("Payment: " + snapshot.data!.payment.toString()),
                  Text("Description: " + snapshot.data!.description),
                  Text("Permit: " + snapshot.data!.requirePermit),
                  Text("Organiser: " + snapshot.data!.organiserName),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      haveJoin
                          ? TextButton(
                              style: TextButton.styleFrom(
                                primary: Colors.red,
                                // onSurface: Colors.red,
                              ),
                              onPressed: () async {
                                if (await unjoinActivity(
                                    widget.user,
                                    widget.selectedGroup.id,
                                    widget.activityId,
                                    widget.connection)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Request Unjoin Success'),
                                        content: Text(
                                            'Your have unjoin the activity'),
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

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GroupInfo(
                                              selectedGroup:
                                                  widget.selectedGroup,
                                              connection: widget.connection,
                                              user: widget.user)));
                                }
                              },
                              child: Text("Unjoin"),
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                primary: Colors.green,
                                // onSurface: Colors.red,
                              ),
                              onPressed: () async {
                                if (await joinActivity(
                                    widget.user,
                                    widget.selectedGroup.id,
                                    widget.activityId,
                                    widget.connection,
                                    "member")) {
                                  Navigator.pop(context);

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Request Join Success'),
                                        content:
                                            Text('Your have join the activity'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ActivityPage(
                                                          activityId:
                                                              widget.activityId,
                                                          user: widget.user,
                                                          connection:
                                                              widget.connection,
                                                          haveJoin:
                                                              !widget.haveJoin,
                                                          // havePaid: false,
                                                          selectedGroup: widget
                                                              .selectedGroup,
                                                        )),
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
                              child: Text("Join"),
                            ),
                      Visibility(
                        visible: isCreator,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.yellow,
                            // onSurface: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditActivityPage(
                                        activityData: snapshot.requireData,
                                        connection: widget.connection,
                                        selectedGroup: widget.selectedGroup,
                                        user: widget.user,
                                      )),
                            );
                          },
                          child: Text(
                            "Edit",
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isCreator,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () async {
                            if (await deleteActivity(widget.selectedGroup.id,
                                widget.activityId, widget.connection)) {
                            } else {}
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupInfo(
                                        connection: widget.connection,
                                        selectedGroup: widget.selectedGroup,
                                        user: widget.user,
                                      )),
                            );
                          },
                          child: Text(
                            "Delete",
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !isCreator && !havePaid,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () async {
                            String paymentResult = await makePayment(
                              snapshot.data!.organiserId,
                              widget.user.userId,
                              widget.activityId,
                              widget.connection,
                            );

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Payment result'),
                                  content: Text(paymentResult),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GroupInfo(
                                              connection: widget.connection,
                                              selectedGroup:
                                                  widget.selectedGroup,
                                              user: widget.user,
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
                            print("hello");
                          },
                          child: Text(
                            "Make Payment",
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }

        // By default, show a loading spinner.
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
