import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../../group_info/join_group/index.dart';
import '../../query.dart';
import 'data.dart';

class GroupSearchListWidget extends StatelessWidget {
  final InfoItem groupList;
  final PostgreSQLConnection connection;
  final User user;
  const GroupSearchListWidget(this.groupList, this.user, this.connection,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // print(data.title)
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => JoinGroupPage(
                    group: groupList,
                    connection: connection,
                    user: user,
                  )),
        );
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 10)),
            // Image.network(groupList.imageUrl, width: 120, height: 90),
            Image.memory(groupList.imageUrl!, width: 120, height: 90),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(groupList.groupName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.green)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
