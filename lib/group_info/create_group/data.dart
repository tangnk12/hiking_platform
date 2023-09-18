import 'package:postgres/postgres.dart';

import '../../Home/search_group_list/data.dart';

Future<List<Group>> getGroupsByNameAndCreator(
    int creatorId, String groupName, PostgreSQLConnection connection) async {
  List<Map<String, Map<String, dynamic>>> results =
      await connection.mappedResultsQuery(
    'SELECT group_id, group_name, group_image, creator_id FROM "group" WHERE creator_id = @creatorId AND group_name = @groupName',
    substitutionValues: {'creatorId': creatorId, 'groupName': groupName},
  );

  List<Group> groups = [];
  for (var result in results) {
    groups.add(Group.fromMap(result['group']!));
  }
  return groups;
}

Future<Group> getCreateGroup(
    int creatorId, String groupName, PostgreSQLConnection connection) async {
  // Retrieve user groups
  List<Map<String, Map<String, dynamic>>> results =
      await connection.mappedResultsQuery(
    'SELECT group_id, group_name, group_image, creator_id FROM "group" WHERE creator_id = @creatorId AND group_name = @groupName',
    substitutionValues: {'creatorId': creatorId, 'groupName': groupName},
  );

  if (results.isNotEmpty) {
    // If the group exists, return data as a Group object
    return Group.fromMap(results.first["group"]!);
  } else {
    // Otherwise, return null
    return Group(
        id: -1, groupName: '', imageUrl: '', creatorId: -1, description: '');
  }
}
