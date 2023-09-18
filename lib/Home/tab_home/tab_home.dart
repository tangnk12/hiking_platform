// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hiking_platform/group_info/create_group/index.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';
import '../tab_home_group_list/index.dart';

// class TabHome extends StatelessWidget {
//   const TabHome({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Groups"),
//         backgroundColor: Colors.green,
//       ),
//       body: ListView(
//         // ignore: prefer_const_literals_to_create_immutables
//         children: <Widget>[
//           Text('Groups',
//               style:
//                   TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
//           // CommonSwipper(),
//           // IndexNavigator(),
//           // IndexRecommond(),
//           GroupInfo(
//             showTitle: true,
//             userId: 1,
//           ),

//           Text('Showing content area'),
//         ],
//       ),
//     );
//   }
// }
class TabHome extends StatelessWidget {
  final PostgreSQLConnection connection;
  final User user;

  const TabHome({Key? key, required this.user, required this.connection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hiking Family"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text('Your Groups',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 20)),
            GroupHomeInfo(
              user: user,
              connection: connection,
            ),
          ],
        ),
      ),
      //create group button, proceed to Create group page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateGroup(
                        connection: connection,
                        currUser: user,
                      )));
        },
      ),
    );
  }
}
