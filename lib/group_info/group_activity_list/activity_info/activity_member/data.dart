import 'package:postgres/postgres.dart';
import 'dart:typed_data';
import 'dart:convert';

class ActivityMemberClass {
  final int memberId;
  final String memberName;
  final String memberRole;
  final Uint8List? avatarUrl;
  final bool isPaid;
  final bool isCheckin;
  final bool isCheckout;
  late String location;

  ActivityMemberClass(
      {required this.memberId,
      required this.memberName,
      required this.memberRole,
      required this.avatarUrl,
      required this.isPaid,
      required this.isCheckin,
      required this.isCheckout,
      required this.location});
}

Future<List<ActivityMemberClass>> getActivityMemberList(
  PostgreSQLConnection connection,
  int activityId,
) async {
  // Retrieve all members
  List<ActivityMemberClass> members = [];

  List<List<dynamic>> results = await connection.query(
    'SELECT activity_member.user_id,activity_member.user_role,activity_member.member_checkin,activity_member.member_checkout,activity_member.user_paid, activity_member.submit_gps FROM activity_member WHERE activity_member.activity_id=@activityId ',
    substitutionValues: {
      'activityId': activityId,
    },
  );

  // For each member, add it to the members list
  for (var result in results) {
    try {
      int activityMemberId = int.parse(result[0]);

      String memberRole = result[1];
      bool isCheckin = result[2];
      bool isCheckout = result[3];
      bool isPaid = result[4];
      String submitLocation = "";
      if (result[5] == null) {
        submitLocation = "no submission";
      } else {
        submitLocation = result[5];
      }

      List<List<dynamic>> userResult = await connection.query(
        'SELECT user_name,avatar FROM "user" WHERE user_id=@userId',
        substitutionValues: {'userId': activityMemberId},
      );

      String memberName = userResult[0][0];
      String? memberAvatar = userResult[0][1];
      Uint8List? memberAvatarPicture;
      if (memberAvatar != null && memberAvatar.isNotEmpty) {
        memberAvatarPicture = base64Decode(memberAvatar);
      }
      // Uint8List memberAvatarPicture = base64Decode(memberAvatar);
      // String submitLocation = userResult[0][5];

      members.add(ActivityMemberClass(
          memberId: activityMemberId,
          memberName: memberName,
          memberRole: memberRole,
          avatarUrl: memberAvatarPicture,
          isCheckin: isCheckin,
          isCheckout: isCheckout,
          isPaid: isPaid,
          location: submitLocation));
    } catch (e) {
      print(e.toString());
    }
  }

  return members;
}

Future<bool> kickActivityMember(
    int memberId, int activityId, PostgreSQLConnection connection) async {
  // Retrieve all members

  var results = await connection.query(
    'SELECT user_id, group_id FROM activity_member WHERE user_id = @userId AND activity_id = @activityId ',
    substitutionValues: {
      'userId': memberId,
      'activityId': activityId,
    },
  );

  // For each member, add it to the members list
  if (results.isNotEmpty) {
    // If the user is already in thegroup, delete the user from member_list where the user_id=@userId and group_id=@GroupId
    await connection.query(
      'DELETE FROM activity_member WHERE user_id = @userId AND activity_id = @activityId ',
      substitutionValues: {
        'userId': memberId,
        'activityId': activityId,
      },
    );
    return true;
  }
  return false;
}

Future<bool> asignActivityGuide(int memberId, int activityId,
    PostgreSQLConnection connection, String roleAdmin) async {
  // Retrieve all members

  var results = await connection.query(
    'SELECT user_id, activity_id FROM activity_member WHERE user_id = @userId AND activity_id = @activityId ',
    substitutionValues: {
      'userId': memberId,
      'activityId': activityId,
    },
  );

  // For each member, add it to the members list
  if (results.isNotEmpty) {
    // If the user is already in thegroup, delete the user from member_list where the user_id=@userId and group_id=@GroupId
    await connection.query(
      'UPDATE activity_member SET user_role = \'guide\' WHERE user_id = @userId AND activity_id = @activityId;',
      substitutionValues: {
        'userId': memberId,
        'activityId': activityId,
      },
    );
    return true;
  }
  return false;
}

Future<bool> asignActivityNormalUser(int memberId, int activityId,
    PostgreSQLConnection connection, String roleAdmin) async {
  // Retrieve all members

  var results = await connection.query(
    'SELECT user_id, group_id FROM activity_member WHERE user_id = @userId AND activity_id = @activityId',
    substitutionValues: {
      'userId': memberId,
      'activityId': activityId,
    },
  );

  // For each member, add it to the members list
  if (results.isNotEmpty) {
    // If the user is already in thegroup, delete the user from member_list where the user_id=@userId and group_id=@GroupId
    await connection.query(
      'UPDATE activity_member SET user_role =\'normal\' WHERE user_id = @userId AND activity_id = @activityId;',
      substitutionValues: {
        'userId': memberId,
        'activityId': activityId,
      },
    );
    return true;
  }
  return false;
}
