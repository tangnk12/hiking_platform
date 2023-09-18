import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/group_activity_list/activity_list_widget.dart';
import 'package:hiking_platform/query.dart';
import 'package:postgres/postgres.dart';

import 'data.dart';

class ActivityListInfo extends StatelessWidget {
  final PostgreSQLConnection connection;
  final InfoItem selectedGroup;

  final User user;
  const ActivityListInfo(
      {Key? key,
      required this.connection,
      required this.user,
      required this.selectedGroup});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FutureBuilder<List<ActivityList>>(
          future: getActivityList(connection, selectedGroup.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Row(
                  children: snapshot.data!
                      .map((item) => SizedBox(
                            child: ActivityListWidget(
                              data: item,
                              connection: connection,
                              user: user,
                              selectedGroup: selectedGroup,
                            ),
                          ))
                      .toList(),
                );
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
