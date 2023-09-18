import 'package:flutter/material.dart';
import 'package:hiking_platform/group_info/group_activity_list/activity_info/index.dart';

import 'package:hiking_platform/group_info/group_activity_list/data.dart';
import 'package:hiking_platform/query.dart';
import 'package:postgres/postgres.dart';

import '../../Home/search_group_list/data.dart';

class ActivityListWidget extends StatelessWidget {
  final ActivityList data;
  final InfoItem selectedGroup;
  final PostgreSQLConnection connection;
  final User user;

  const ActivityListWidget(
      {required this.data,
      super.key,
      required this.connection,
      required this.user,
      required this.selectedGroup});

  @override
  Widget build(BuildContext context) {
    bool haveJoin = false;

    return Container(
      width: MediaQuery.of(context).size.width * 0.33,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              print(data.activityName);
              if (await judgeHaveJoin(
                  data.activityId, user.userId, connection)) {
                haveJoin = true;
              }
              // if (await judgeHavePaid(
              //     data.activityId, user.userId, connection)) {
              //   havePaid = true;
              // }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivityPage(
                          activityId: data.activityId,
                          connection: connection,
                          user: user,
                          selectedGroup: selectedGroup,
                          haveJoin: haveJoin,
                        )),
              );
            },
            child: Container(
              child: Column(
                children: [SizedBox(height: 10.0), Text(data.activityName)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
