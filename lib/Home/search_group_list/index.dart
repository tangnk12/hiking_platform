import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:postgres/postgres.dart';

import '../../query.dart';
import 'group_list_widget.dart';

class GroupListSearch extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User user;

  const GroupListSearch(
      {Key? key, required this.connection, required this.user});

  @override
  _GroupListSeachState createState() => _GroupListSeachState();
}

class _GroupListSeachState extends State<GroupListSearch> {
  late Future<List<InfoItem>> _infoDataFuture;
  late Future<List<InfoItem>> _newinfoDataFuture;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _infoDataFuture = _getGroupsList();
    _newinfoDataFuture = _infoDataFuture;
  }

  Future<List<InfoItem>> _getGroupsList() async {
    final groups = await getGroupsList(widget.connection);

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Groups To Explore"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  _newinfoDataFuture = searchOnChanged(value, _infoDataFuture);
                });
              },
              decoration: InputDecoration(
                icon: Icon(Icons.search, size: 30),
                hintText: "Type the group name to search",
                border: InputBorder.none,
              ),
            ),
            FutureBuilder<List<InfoItem>>(
              future: _newinfoDataFuture,
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
                      // Padding(padding: EdgeInsets.only(left: 100)),
                      // if (true)
                      //   Text(
                      //     'Group To Explore',
                      //     style: TextStyle(fontSize: 24, color: Colors.blue),
                      //   ),
                      Column(
                        children: snapshot.data!
                            .map((item) => GroupSearchListWidget(
                                item, widget.user, widget.connection))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
        ));
  }

  Future<List<InfoItem>> searchOnChanged(
      String value, Future<List<InfoItem>> data) async {
    // Wait for the data to be fetched
    final infoData = await data;

    // If the input text is empty, return the original data
    if (value.isEmpty) {
      return infoData;
    }

    // Filter the data based on the input text
    final filteredData = infoData
        .where((item) =>
            item.groupName.toLowerCase().contains(value.toLowerCase()))
        .toList();

    return filteredData;
  }
}
