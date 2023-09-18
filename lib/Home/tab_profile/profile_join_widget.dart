import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:postgres/postgres.dart';
import '../../group_info/index.dart';
import '../../query.dart';

class ProfileGroupListWidget extends StatelessWidget {
  final InfoItem selectedGroup;
  final PostgreSQLConnection connection;
  final User user;

  const ProfileGroupListWidget({
    Key? key,
    required this.selectedGroup,
    required this.connection,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.33,
      child: Row(
        children: [
          GestureDetector(
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
              width: 100.0,
              height: 100.0,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      selectedGroup.imageUrl!,
                      fit: BoxFit.cover,
                      width: 100.0,
                      height: 50.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(selectedGroup.groupName),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

        // onTap: () {
        //   // data.onTapHandle!(context);
        // },
        // child: Container(
        //   margin: EdgeInsets.only(top: 30),
        //   //height: 20,
        //   width: MediaQuery.of(context).size.width * 0.33,
        //   // decoration: BoxDecoration(color: Colors.red),
        //   child: Column(
        //     children: [
        //       Image.asset(
        //         data.imageUrl,
        //         scale: 1.5,
        //       ),
        //       Text(data.title)
        //     ],
        //   ),
        // ),
 