import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/view_member/view_member_widget.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';
import 'data.dart';

class ViewMember extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User user;
  final InfoItem selectedGroup;
  final bool isAdmin;

  const ViewMember(
      {Key? key,
      required this.connection,
      required this.user,
      required this.selectedGroup,
      required this.isAdmin});

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<ViewMember> {
  late Future<List<Member>> memberList;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    memberList = _getMemberList();
  }

  Future<List<Member>> _getMemberList() async {
    final members =
        await getMemberList(widget.connection, widget.selectedGroup.id);

    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Members"),
      ),
      body: Column(children: [
        FutureBuilder<List<Member>>(
          future: memberList,
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
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Column(
                    children: snapshot.data!
                        .map((item) => MemberListWidget(
                              member: item,
                              user: widget.user,
                              connection: widget.connection,
                              selectedGroup: widget.selectedGroup,
                              isAdmin: widget.isAdmin,
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }
}
