import 'package:flutter/material.dart';
import 'package:hiking_platform/group_info/index.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';
import '../search_group_list/data.dart';

var textStyle = TextStyle(color: Colors.black54);

class GroupListWidget extends StatelessWidget {
  final InfoItem selectedGroup;
  final PostgreSQLConnection connection;
  final User user;

  const GroupListWidget(this.selectedGroup, this.connection,
      {Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupInfo(
              selectedGroup: selectedGroup,
              connection: connection,
              user: user,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 20)),
            // Image.network(selectedGroup.imageUrl,
            //     width: 120, height: 90, fit: BoxFit.cover),
            Image.memory(selectedGroup.imageUrl!,
                width: 120, height: 90, fit: BoxFit.cover),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedGroup.groupName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
