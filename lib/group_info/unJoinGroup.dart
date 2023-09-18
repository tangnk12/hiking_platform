import 'package:postgres/postgres.dart';

Future<bool> unJoinGroup(
    int userId, int groupId, PostgreSQLConnection connection) async {
  // Retrieve user groups
  var results = await connection.query(
    'SELECT user_id, group_id FROM member_list WHERE user_id = @userId AND group_id = @groupId ',
    substitutionValues: {
      'userId': userId,
      'groupId': groupId,
    },
  );

  if (results.isNotEmpty) {
    // If the user is already in the activity, delete the row from activity_member where the user_id=@userId and activity_id=@activityId
    await connection.query(
      'DELETE FROM member_list WHERE user_id = @userId AND group_id = @groupId ',
      substitutionValues: {
        'userId': userId,
        'groupId': groupId,
      },
    );
    return true;
  }
  return false;
}

Future<bool> deleteGroup(
    int userId, int groupId, PostgreSQLConnection connection) async {
  // Retrieve user groups
  var results = await connection.query(
    'SELECT user_id, group_id FROM member_list WHERE user_id = @userId AND group_id = @groupId ',
    substitutionValues: {
      'userId': userId,
      'groupId': groupId,
    },
  );

  if (results.isNotEmpty) {
    // If the user is already in the activity, delete the row from activity_member where the user_id=@userId and activity_id=@activityId
    await connection.query(
      'DELETE FROM \"group\" WHERE creator_id = @userId AND group_id = @groupId ',
      substitutionValues: {
        'userId': userId,
        'groupId': groupId,
      },
    );
    await connection.query(
      'DELETE FROM member_list WHERE group_id = @groupId ',
      substitutionValues: {
        'groupId': groupId,
      },
    );
    await connection.query(
      'DELETE FROM activity_list WHERE group_id = @groupId ',
      substitutionValues: {
        'groupId': groupId,
      },
    );
    await connection.query(
      'DELETE FROM activity_member WHERE group_id = @groupId ',
      substitutionValues: {
        'groupId': groupId,
      },
    );

    return true;
  }
  return false;
}
