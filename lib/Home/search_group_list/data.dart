import 'package:postgres/postgres.dart';

import 'dart:convert';
import 'dart:typed_data';

class InfoItem {
  final String groupName;
  final Uint8List? imageUrl;
  final int id;
  final String description;

  const InfoItem(
      {required this.id,
      required this.groupName,
      required this.imageUrl,
      required this.description});
}

class Group {
  final int id;
  final String imageUrl;
  final String groupName;
  final int creatorId;
  final String description;

  Group(
      {required this.id,
      required this.imageUrl,
      required this.groupName,
      required this.creatorId,
      required this.description});

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['group_id'],
      imageUrl: map['group_image'],
      groupName: map['group_name'],
      creatorId: map['creator_id'],
      description: map['description'] ?? '', // Handle NULL case
    );
  }
}

Future<List<InfoItem>> getGroupsList(PostgreSQLConnection connection) async {
  // Retrieve all groups
  List<Group> groups = [];

  List<List<dynamic>> results = await connection.query(
    'SELECT group_id, group_name, group_image,creator_id,description FROM "group";',
  );

  for (var row in results) {
    groups.add(Group(
      id: row[0] as int,
      groupName: row[1] as String,
      imageUrl: row[2] as String,
      creatorId: row[3] as int,
      description: row[4] as String,
    ));
  }

  // Convert groups to InfoItems
  List<InfoItem> infoItems = [];

  for (var group in groups) {
    infoItems.add(InfoItem(
        id: group.id,
        groupName: group.groupName,
        imageUrl: base64Decode(group.imageUrl),
        description: group.description));
  }

  return infoItems;
}
