import 'package:postgres/postgres.dart';

class ActivityList {
  final int activityId;
  final String activityName;
  //final String imageUrl;

  // final int groupId;

  ActivityList({
    required this.activityId,
    // required this.imageUrl,
    required this.activityName,
    /*required this.groupId*/
  });
}

Future<List<ActivityList>> getActivityList(
    PostgreSQLConnection connection, int groupId) async {
  // Retrieve all groups
  List<ActivityList> activityList = [];

  List<List<dynamic>> results = await connection.query(
    'SELECT activity_id, activity_name FROM activity_list WHERE group_id = @groupId ;',
    substitutionValues: {'groupId': groupId},
  );

  for (var row in results) {
    activityList.add(ActivityList(
      activityId: row[0] as int,
      activityName: row[1] as String,
      //imageUrl: row[2] as String,
    ));
  }
  return activityList;
}

Future<bool> judgeHaveJoin(
  int activityId,
  int userId,
  PostgreSQLConnection connection,
) async {
  var results = await connection.query(
    'SELECT activity_id, user_id FROM activity_member WHERE user_id = @userId AND activity_id=@activityId ;',
    substitutionValues: {'userId': userId, 'activityId': activityId},
  );
  if (results.isNotEmpty) {
    return true;
  }
  return false;
}

Future<bool> judgeHavePaid(
  int activityId,
  int userId,
  PostgreSQLConnection connection,
) async {
  var results = await connection.query(
    'SELECT activity_id, user_id, user_paid FROM activity_member WHERE user_id = @userId AND activity_id = @activityId ;',
    substitutionValues: {'userId': userId, 'activityId': activityId},
  );

  if (results.isNotEmpty) {
    bool userPaidStatus = results[0][2];
    return userPaidStatus;
  }

  return false;
}
