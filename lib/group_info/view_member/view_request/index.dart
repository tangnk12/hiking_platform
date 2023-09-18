import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/view_member/view_request/request_widget.dart';
import 'package:postgres/postgres.dart';

import '../../../query.dart';
import 'data.dart';

class GroupRequest extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User user;
  final InfoItem selectedGroup;

  const GroupRequest(
      {Key? key,
      required this.connection,
      required this.user,
      required this.selectedGroup});

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<GroupRequest> {
  late Future<List<Request>> requestList;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestList = _getRequestList();
  }

  Future<List<Request>> _getRequestList() async {
    final members =
        await getRequestList(widget.connection, widget.selectedGroup.id);

    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Request"),
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
        FutureBuilder<List<Request>>(
          future: requestList,
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
                        .map((item) => RequestListWidget(
                              requestMember: item,
                              selectedGroup: widget.selectedGroup,
                              user: widget.user,
                              connection: widget.connection,
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
