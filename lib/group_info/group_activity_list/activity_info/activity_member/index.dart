import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';

import 'package:postgres/postgres.dart';

import '../../../../query.dart';

import 'activity_member_widget.dart';
import 'data.dart';

class ActivityMemberPage extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User user;
  final int selectedActivityId;
  final InfoItem selectedGroup;
  final bool isOrganiser;

  const ActivityMemberPage(
      {Key? key,
      required this.connection,
      required this.user,
      required this.selectedActivityId,
      required this.selectedGroup,
      required this.isOrganiser});

  @override
  _ActivityMemberListState createState() => _ActivityMemberListState();
}

class _ActivityMemberListState extends State<ActivityMemberPage> {
  late Future<List<ActivityMemberClass>> activityMemberList;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    activityMemberList = _getActivityMemberList();
  }

  Future<List<ActivityMemberClass>> _getActivityMemberList() async {
    final members = await getActivityMemberList(
        widget.connection, widget.selectedActivityId);

    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Activity Member"),
      ),
      body: Column(children: [
        // TextField(
        //   controller: searchController,
        //   onChanged: (value) {
        //     setState(() {
        //       _newinfoDataFuture = searchOnChanged(value, _infoDataFuture);
        //     });
        //   },
        //   decoration: InputDecoration(
        //     icon: Icon(Icons.search, size: 30),
        //     hintText: "Type the group name to search",
        //     border: InputBorder.none,
        //   ),
        // ),
        FutureBuilder<List<ActivityMemberClass>>(
          future: activityMemberList,
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
                  if (true) Padding(padding: EdgeInsets.only(top: 20)),
                  Column(
                    children: snapshot.data!
                        .map((item) => ActivityMemberListWidget(
                              activityMember: item,
                              user: widget.user,
                              connection: widget.connection,
                              selectedGroup: widget.selectedGroup,
                              selectedActivityId: widget.selectedActivityId,
                              isOrganiser: widget.isOrganiser,
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

  // Future<List<InfoItem>> searchOnChanged(
  //     String value, Future<List<InfoItem>> data) async {
  //   // Wait for the data to be fetched
  //   final infoData = await data;

  //   // If the input text is empty, return the original data
  //   if (value.isEmpty) {
  //     return infoData;
  //   }

  //   // Filter the data based on the input text
  //   final filteredData = infoData
  //       .where((item) => item.title.toLowerCase().contains(value.toLowerCase()))
  //       .toList();

  //   return filteredData;
  // }
}
