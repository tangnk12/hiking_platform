import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';

import 'package:hiking_platform/Home/tab_profile/profile_join_widget.dart';
import 'package:hiking_platform/Home/tab_profile/userGroupData.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';

class ProfileGroup extends StatefulWidget {
  final User user;
  final PostgreSQLConnection connection;

  const ProfileGroup({Key? key, required this.user, required this.connection});
  @override
  ProfileGroupState createState() => ProfileGroupState();
}

class ProfileGroupState extends State<ProfileGroup> {
  late Future<List<InfoItem>> _infoDataFuture;
  @override
  void initState() {
    super.initState();
    _infoDataFuture = _getGroupsInfoForUser(widget.user.userId);
  }

  Future<List<InfoItem>> _getGroupsInfoForUser(int userId) async {
    final groups = await getGroupsInfoForUser(userId, widget.connection);

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<InfoItem>>(
        future: _infoDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: snapshot.data!
                  .map((item) => SizedBox(
                        width: 150.0,
                        height: 150.0,
                        child: ProfileGroupListWidget(
                          selectedGroup: item,
                          connection: widget.connection,
                          user: widget.user,
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
