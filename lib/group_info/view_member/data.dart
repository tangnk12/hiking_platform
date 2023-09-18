import 'package:postgres/postgres.dart';
import 'dart:convert';
import 'dart:typed_data';

class Member {
  final int memberId;
  final String memberName;
  final String memberRole;
  final Uint8List? memberAvatar;

  const Member({
    required this.memberId,
    required this.memberName,
    required this.memberRole,
    required this.memberAvatar,
  });
}

Future<List<Member>> getMemberList(
  PostgreSQLConnection connection,
  int groupId,
) async {
  // Retrieve all members
  List<Member> members = [];
  print("here");

  List<List<dynamic>> results = await connection.query(
    'SELECT member_list.user_id,member_list.member_role FROM member_list WHERE member_list.group_id=@groupId AND member_list.accepted=@accepted',
    substitutionValues: {'groupId': groupId, 'accepted': true},
  );

  // For each member, add it to the members list
  for (var result in results) {
    int memberId = result[0];
    String memberRole = result[1];

    List<List<dynamic>> userResult = await connection.query(
      'SELECT user_name,avatar FROM "user" WHERE user_id=@userId',
      substitutionValues: {'userId': memberId},
    );

    String memberName = userResult[0][0];

    String? userAvatar = userResult[0][1];

    Uint8List? memberAvatarPicture;
    if (userAvatar != null && userAvatar.isNotEmpty) {
      memberAvatarPicture = base64Decode(userAvatar);
    }

    members.add(Member(
        memberId: memberId,
        memberName: memberName,
        memberRole: memberRole,
        memberAvatar: memberAvatarPicture));
  }
  return members;
}

Future<bool> kickMember(
    int memberId, int groupId, PostgreSQLConnection connection) async {
  // Retrieve all members

  var results = await connection.query(
    'SELECT user_id, group_id FROM member_list WHERE user_id = @userId AND group_id = @groupId ',
    substitutionValues: {
      'userId': memberId,
      'groupId': groupId,
    },
  );

  // For each member, add it to the members list
  if (results.isNotEmpty) {
    // If the user is already in thegroup, delete the user from member_list where the user_id=@userId and group_id=@GroupId
    await connection.query(
      'DELETE FROM member_list WHERE user_id = @userId AND group_id = @groupId ',
      substitutionValues: {
        'userId': memberId,
        'groupId': groupId,
      },
    );
    return true;
  }
  return false;
}

Future<bool> asignAdmin(int memberId, int groupId,
    PostgreSQLConnection connection, String roleAdmin) async {
  // Retrieve all members

  var results = await connection.query(
    'SELECT user_id, group_id,accepted FROM member_list WHERE user_id = @userId AND group_id = @groupId AND accepted=@accepted',
    substitutionValues: {
      'userId': memberId,
      'groupId': groupId,
      'accepted': true,
    },
  );

  // For each member, add it to the members list
  if (results.isNotEmpty) {
    // If the user is already in thegroup, delete the user from member_list where the user_id=@userId and group_id=@GroupId
    await connection.query(
      'UPDATE member_list SET member_role = \'admin\' WHERE user_id = @userId AND group_id = @groupId;',
      substitutionValues: {
        'userId': memberId,
        'groupId': groupId,
      },
    );
    return true;
  }
  return false;
}

Future<bool> asignNormalUser(int memberId, int groupId,
    PostgreSQLConnection connection, String roleAdmin) async {
  // Retrieve all members

  var results = await connection.query(
    'SELECT user_id, group_id,accepted FROM member_list WHERE user_id = @userId AND group_id = @groupId AND accepted=@accepted',
    substitutionValues: {
      'userId': memberId,
      'groupId': groupId,
      'accepted': true,
    },
  );

  // For each member, add it to the members list
  if (results.isNotEmpty) {
    // If the user is already in thegroup, delete the user from member_list where the user_id=@userId and group_id=@GroupId
    await connection.query(
      'UPDATE member_list SET member_role =\'normal\' WHERE user_id = @userId AND group_id = @groupId;',
      substitutionValues: {
        'userId': memberId,
        'groupId': groupId,
      },
    );
    return true;
  }
  return false;
}
