import 'package:postgres/postgres.dart';

Future<bool> joinGroup(int userId, int groupId, PostgreSQLConnection connection,
    bool accepted, String role) async {
  // Retrieve user groups
  var results = await connection.query(
    'SELECT user_id, group_id FROM member_list WHERE user_id = @userId AND group_id = @groupId',
    substitutionValues: {'userId': userId, 'groupId': groupId},
  );

  if (results.isNotEmpty) {
    // If the user is already in the group, return false
    return false;
  } else {
    // Otherwise, insert the user and group information into user_group table
    await connection.query(
      'INSERT INTO member_list (user_id, group_id,member_role, accepted) VALUES (@userId, @groupId,@memberRole,@accepted)',
      substitutionValues: {
        'userId': userId,
        'groupId': groupId,
        'memberRole': role,
        'accepted': accepted,
      },
    );
    // Return true
    return true;
  }
}
