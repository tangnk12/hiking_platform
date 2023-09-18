import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/index.dart';
import '../../query.dart';

import '../search_group_list/data.dart';
import 'data.dart';
import 'group_list_widget.dart';
import 'package:postgres/postgres.dart';

class GroupHomeInfo extends StatefulWidget {
  final User user;

  final PostgreSQLConnection connection;

  const GroupHomeInfo({Key? key, required this.user, required this.connection});

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupHomeInfo> {
  late Future<List<InfoItem>> _infoDataFuture;

  @override
  void initState() {
    super.initState();
    _infoDataFuture = _getGroupsInfoForUser(widget.user.userId);
    setState(() {}); // move setState call here
  }

  Future<List<InfoItem>> _getGroupsInfoForUser(int userId) async {
    final groups = await getGroupsInfoForUser(userId, widget.connection);

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          // Trigger the refresh by calling _getGroupsInfoForUser again
          return _getGroupsInfoForUser(widget.user.userId).then((updatedList) {
            setState(() {
              // Update the _infoDataFuture with the updated list
              _infoDataFuture = Future.value(updatedList);
            });
          });
        },
        child: FutureBuilder<List<InfoItem>>(
          //get user joined group, display it
          future: _infoDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            return Container(
              child: Column(
                children: [
                  //the widget represent the groups list
                  Column(
                    children: snapshot.data!
                        .map((item) => GroupListWidget(
                              item,
                              widget.connection,
                              user: widget.user,
                            ))
                        .toList(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupListSearch(
                                    connection: widget.connection,
                                    user: widget.user,
                                  )));
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left: 40)),
                          Text("Discover more group"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
