import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/view_member/view_request/index.dart';
import 'package:postgres/postgres.dart';

import '../../../query.dart';
import 'data.dart';

class RequestListWidget extends StatelessWidget {
  final Request requestMember;
  final InfoItem selectedGroup;
  final PostgreSQLConnection connection;
  final User user;

  const RequestListWidget(
      {super.key,
      required this.requestMember,
      required this.selectedGroup,
      required this.connection,
      required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              try {
                return Image.memory(
                  requestMember.avatarUrl!,
                  width: 120,
                  height: 90,
                );
              } catch (e) {
                print("Error loading image from memory: $e");
                return Image.network(
                  "https://tva1.sinaimg.cn/large/008i3skNgy1gsuhtensa6j30lk0li76f.jpg",
                  width: 120,
                  height: 90,
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
                  requestMember.requestName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      // Background color
                    ),
                    onPressed: () async {
                      if (await acceptAsMember(requestMember.requestId,
                          selectedGroup.id, connection)) {
                        //  Navigator.pop(context);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupRequest(
                                      user: user,
                                      connection: connection,
                                      selectedGroup: selectedGroup,
                                    )));
                      } else {}
                    },
                    child: Text('Accept')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Background color
                    ),
                    onPressed: () async {
                      if (await declineAsMember(requestMember.requestId,
                          selectedGroup.id, connection)) {
                        Navigator.pop(context);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupRequest(
                                      user: user,
                                      connection: connection,
                                      selectedGroup: selectedGroup,
                                    )));
                      } else {}
                    },
                    child: Text('Decline')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
