import 'package:postgres/postgres.dart';
import '../../Home/search_group_list/data.dart';

Future<int> getCreateActivity(int creatorId, String activityName,
    InfoItem curGroup, PostgreSQLConnection connection) async {
  // Retrieve activity with given organizer ID and group ID
  List results = await connection.mappedResultsQuery(
    'SELECT activity_id FROM activity_list WHERE organiser_id = @creatorId AND group_id = @groupId AND activity_name=@activityName',
    substitutionValues: {
      'creatorId': creatorId,
      'groupId': curGroup.id,
      'activityName': activityName
    },
  );

  if (results.isNotEmpty) {
    // If the activity exists, return its ID
    var firstRow = results.last.values.last;
    return firstRow['activity_id'] as int;
  } else {
    // Otherwise, return -1
    return -1;
  }
}
