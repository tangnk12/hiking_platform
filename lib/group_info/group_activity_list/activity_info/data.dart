import 'dart:ffi';

import 'package:hiking_platform/query.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:geocoding/geocoding.dart';

class ActivityInfo {
  //final String imageUrl;
  final int activityId;
  final int organiserId;
  final String organiserName;
  final String location;
  final String latLong;
  final String activityName;
  final String description;
  final bool requirePermitBool;
  final String requirePermit;
  final String checkinPassword;
  final String checkoutPassword;

  final double payment;
  final String mapUrl;
  final int groupId;
  final String imageUrl;
  final String date;
  final DateTime dateTime;

  // final int groupId;

  ActivityInfo(
      {required this.activityId,
      required this.organiserId,
      required this.organiserName,
      required this.location,
      required this.latLong,
      required this.activityName,
      required this.description,
      required this.requirePermit,
      required this.requirePermitBool,
      required this.checkinPassword,
      required this.checkoutPassword,
      required this.payment,
      required this.mapUrl,
      required this.groupId,
      required this.imageUrl,
      required this.date,
      required this.dateTime});
}

Future<ActivityInfo> getActivityInfo(
    PostgreSQLConnection connection, int activityId) async {
  // Retrieve an activityInfo
  ActivityInfo activityInfo;

  final results = await connection.query(
    'SELECT activity_id,organiser_id,location,activity_name,description,permit,checkin_password,checkout_password,payment,map_url,group_id,image_url,date FROM "activity_list" WHERE activity_id = @activityId;',
    substitutionValues: {'activityId': activityId},
  );

  final row = results.first;
  // Retrieve the organizer account name based on the organizer_id

  final organizerId = row[1] as int;
  final userResults = await connection.query(
    'SELECT user_name FROM "user" WHERE user_id = @organizerId;',
    substitutionValues: {'organizerId': organizerId},
  );
  final userRow = userResults.first;
  final organizerName = userRow[0] as String;
  String requirePermition;
  if (row[5] == false) {
    requirePermition = "No need";
  } else {
    requirePermition = "Required";
  }
  final dateFromDb = row[12] as DateTime;
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final dateString = dateFormatter.format(dateFromDb);
  String realLocation = "unknown location";
  String locationValue = row[2];

  print(locationValue);
  if (locationValue.contains(',')) {
    List<String> coordinates = locationValue.split(',');
    double latitude = double.tryParse(coordinates[0]) ?? 0.0;
    double longitude = double.tryParse(coordinates[1]) ?? 0.0;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, longitude,
          localeIdentifier: 'en');

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String actualLocation = placemark.locality ?? 'Unknown Location';

        realLocation = actualLocation;
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
  }

  activityInfo = ActivityInfo(
      activityId: row[0] as int,
      organiserId: organizerId,
      organiserName: organizerName,
      location: realLocation,
      latLong: locationValue,
      activityName: row[3] as String,
      description: row[4] as String,
      requirePermitBool: row[5],
      requirePermit: requirePermition,
      checkinPassword: row[6] as String,
      checkoutPassword: row[7] as String,
      payment: row[8] as double,
      mapUrl: row[9] as String,
      groupId: row[10] as int,
      imageUrl: row[11] as String,
      date: dateString,
      dateTime: dateFromDb);

  return activityInfo;
}

class GroupMember {
  final int userId;
  final int groupId;
  final Char role;

  GroupMember(this.userId, this.groupId, this.role);
}

Future<bool> joinActivity(User user, int groupId, int activityId,
    PostgreSQLConnection connection, String userRole) async {
  // Retrieve user groups

  // Otherwise, insert the user and group information into user_group table
  await connection.query(
    'INSERT INTO activity_member (user_id,activity_id,group_id,user_paid,user_role,user_ic, user_phone,user_emegency,user_email,member_checkin,member_checkout) VALUES (@userId, @activityId,@groupId,@userPayment,@userRole,@userIc,@userPhone,@userEmegency,@userEmail,@memberCheckin,@memberCheckout)',
    substitutionValues: {
      'userId': user.userId,
      'activityId': activityId,
      'groupId': groupId,
      'userPayment': false,
      'userRole': userRole,
      'userIc': user.userIc,
      'userPhone': user.userPhone,
      'userEmegency': user.emegencyPhone,
      'userEmail': user.userEmail,
      'memberCheckin': false,
      'memberCheckout': false,
    },
  );
  // Return true
  return true;
}

Future<bool> unjoinActivity(User user, int groupId, int activityId,
    PostgreSQLConnection connection) async {
  // Retrieve user groups
  var results = await connection.query(
    'SELECT user_id, group_id,activity_id FROM activity_member WHERE user_id = @userId AND group_id = @groupId AND activity_id=@activityId',
    substitutionValues: {
      'userId': user.userId,
      'groupId': groupId,
      'activityId': activityId
    },
  );

  if (results.isNotEmpty) {
    // If the user is already in the activity, delete the row from activity_member where the user_id=@userId and activity_id=@activityId
    await connection.query(
      'DELETE FROM activity_member WHERE user_id = @userId AND group_id = @groupId AND activity_id = @activityId',
      substitutionValues: {
        'userId': user.userId,
        'groupId': groupId,
        'activityId': activityId,
      },
    );
    return true;
  }
  return false;
}

Future<bool> deleteActivity(
    int groupId, int activityId, PostgreSQLConnection connection) async {
  var results = await connection.query(
    'SELECT group_id,activity_id FROM activity_list WHERE group_id = @groupId AND activity_id=@activityId',
    substitutionValues: {'groupId': groupId, 'activityId': activityId},
  );

  if (results.isNotEmpty) {
    // If the user is already in the activity, delete the row from activity_member where the user_id=@userId and activity_id=@activityId
    await connection.query(
      'DELETE FROM activity_list WHERE group_id = @groupId AND activity_id = @activityId',
      substitutionValues: {
        'groupId': groupId,
        'activityId': activityId,
      },
    );
    return true;
  } else {
    print("no such activity");
  }
  return false;
}

Future<String> makePayment(int organiserId, int memberId, int activityId,
    PostgreSQLConnection connection) async {
  var result = await connection.query(
    '''
    SELECT u.balance, am.user_paid, al.payment
    FROM "user" AS u
    JOIN activity_member AS am ON u.user_id = am.user_id
    JOIN activity_list AS al ON am.activity_id = al.activity_id
    WHERE u.user_id = @userId AND am.activity_id = @activityId
    ''',
    substitutionValues: {'userId': memberId, 'activityId': activityId},
  );

  if (result.isEmpty) {
    // User or activity not found, return false indicating payment failure
    return "no activity found, please contac the acivity creator";
  }

  var row = result.first;
  var balanceOfMember = row[0] as double;
  var userPaid = row[1] as bool;
  var payment = row[2] as double;

  if (!userPaid && balanceOfMember >= payment) {
    var newBalance = balanceOfMember - payment;

    // Update the user's balance in the user_table
    await connection.query(
      'UPDATE "user" SET balance = @newBalance WHERE user_id = @userId',
      substitutionValues: {'newBalance': newBalance, 'userId': memberId},
    );

    // Set user_paid to true in the activity_member table
    await connection.query(
      'UPDATE activity_member SET user_paid = true WHERE user_id = @userId AND activity_id = @activityId',
      substitutionValues: {'userId': memberId, 'activityId': activityId},
    );
    // Retrieve the organiser's existing balance
    var existingBalanceResult = await connection.query(
      'SELECT balance FROM "user" WHERE user_id = @userId',
      substitutionValues: {'userId': organiserId},
    );
    var existingOrganiser = existingBalanceResult.first;
    var exitingOrganiserBalance = existingOrganiser[0] as double;

// Calculate the new balance
    var newOrganiserBalance = exitingOrganiserBalance + payment;

// Update the organiser's balance
    await connection.query(
      'UPDATE "user" SET balance = @newBalance WHERE user_id = @userId',
      substitutionValues: {
        'newBalance': newOrganiserBalance,
        'userId': organiserId
      },
    );

    return "Payment succesful"; // Payment successful
  } else if (balanceOfMember < payment) {
    return "Please top up first"; // Insufficient balance
  } else if (userPaid) {
    return "you have already pay the activity"; // Insufficient balance or payment already made, payment failed
  } else {
    return "unknown error";
  }
}
