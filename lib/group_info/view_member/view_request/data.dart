import 'package:postgres/postgres.dart';
import 'dart:typed_data';
import 'dart:convert';

class Request {
  final int requestId;
  final String requestName;
  final Uint8List? avatarUrl;

  const Request({
    required this.requestId,
    required this.requestName,
    required this.avatarUrl,
  });
}

Future<List<Request>> getRequestList(
  PostgreSQLConnection connection,
  int groupId,
) async {
  // Retrieve all requests
  List<Request> requestList = [];

  List<List<dynamic>> results = await connection.query(
    'SELECT member_list.user_id FROM member_list WHERE member_list.group_id=@groupId AND member_list.accepted=@accepted',
    substitutionValues: {'groupId': groupId, 'accepted': false},
  );

  // For each request, add it to the requests list
  for (var result in results) {
    int requestId = result[0];

    List<List<dynamic>> userResult = await connection.query(
      'SELECT user_name, avatar FROM "user" WHERE user_id=@userId',
      substitutionValues: {'userId': requestId},
    );

    String requestName = userResult[0][0];
    String? userAvatar = userResult[0][1];

    Uint8List? memberAvatarPicture;
    if (userAvatar != null && userAvatar.isNotEmpty) {
      memberAvatarPicture = base64Decode(userAvatar);
    }

    requestList.add(Request(
      requestId: requestId,
      requestName: requestName,
      avatarUrl: memberAvatarPicture,
    ));
  }

  return requestList;
}

Future<bool> acceptAsMember(
  int userId,
  int groupId,
  PostgreSQLConnection connection,
) async {
  try {
    // Find the row in the member_list table that matches the given user and group IDs
    final result = await connection.query(
      'SELECT * FROM member_list WHERE user_id = @userId AND group_id = @groupId;',
      substitutionValues: {
        'userId': userId,
        'groupId': groupId,
      },
    );

    // If a row was found, update the `accepted` attribute to `true`
    if (result.isNotEmpty) {
      await connection.query(
        'UPDATE member_list SET accepted = true WHERE user_id = @userId AND group_id = @groupId;',
        substitutionValues: {
          'userId': userId,
          'groupId': groupId,
        },
      );
      return true;
    }

    // If no row was found, return false
    return false;
  } catch (e) {
    print('Error accepting member request: $e');
    return false;
  }
}

Future<bool> declineAsMember(
  int userId,
  int groupId,
  PostgreSQLConnection connection,
) async {
  try {
    // Find the row in the member_list table that matches the given user and group IDs
    final result = await connection.query(
      'SELECT * FROM member_list WHERE user_id = @userId AND group_id = @groupId;',
      substitutionValues: {
        'userId': userId,
        'groupId': groupId,
      },
    );

    // If a row was found, delete the request
    if (result.isNotEmpty) {
      await connection.query(
        'DELETE FROM member_list WHERE user_id = @userId AND group_id = @groupId;',
        substitutionValues: {
          'userId': userId,
          'groupId': groupId,
        },
      );
      return true;
    }

    // If no row was found, return false
    return false;
  } catch (e) {
    print('Error deleting member request: $e');
    return false;
  }
}
