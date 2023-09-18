import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:postgres/postgres.dart';
import 'dart:convert';

//User Take Part Class

class UserGroup {
  final int userId;
  final int groupId;

  UserGroup({required this.userId, required this.groupId});
}

class Group {
  final int groupId;
  final String imageUrl;
  final String groupName;
  final String? description;

  Group({
    required this.groupId,
    required this.imageUrl,
    required this.groupName,
    this.description,
  });
}

Future<List<InfoItem>> getGroupsInfoForUser(
    int userId, PostgreSQLConnection connection) async {
  List<UserGroup> userGroups = [];

  // Retrieve user groups
  List<List<dynamic>> results = await connection.query(
    'SELECT user_id, group_id FROM member_list WHERE user_id = @userId AND accepted=true',
    substitutionValues: {'userId': userId},
  );

  for (var row in results) {
    userGroups.add(UserGroup(
      userId: row[0],
      groupId: row[1],
    ));
  }

  // Retrieve group information
  List<Group> groups = [];

  for (var userGroup in userGroups) {
    List<List<dynamic>> results = await connection.query(
      'SELECT group_id, group_name, group_image, description FROM "group" WHERE group_id = @groupId',
      substitutionValues: {'groupId': userGroup.groupId},
    );

    for (var row in results) {
      groups.add(Group(
        groupId: row[0],
        groupName: row[1],
        imageUrl: row[2],
        description: row[3],
      ));
    }
  }

  // Convert groups to InfoItems
  List<InfoItem> infoItems = [];

  for (var group in groups) {
    infoItems.add(InfoItem(
      groupName: group.groupName,
      imageUrl: base64Decode(group.imageUrl),
      id: group.groupId,
      description: group.description ?? '',
    ));
  }

  return infoItems;
}
