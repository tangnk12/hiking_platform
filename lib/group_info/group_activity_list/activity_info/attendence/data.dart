import 'package:postgres/postgres.dart';

import '../data.dart';

Future<String> checkIn(int userId, ActivityInfo activity,
    PostgreSQLConnection connection, String password) async {
  // Retrieve the status of member_checkin and activity time
  var result = await connection.query(
    'SELECT am.member_checkin,am.user_paid, al.date,al.checkin_password FROM activity_member AS am JOIN activity_list AS al ON am.activity_id = al.activity_id WHERE am.user_id = @userId AND am.activity_id = @activityId',
    substitutionValues: {'userId': userId, 'activityId': activity.activityId},
  );

  if (result.isEmpty) {
    return "there are no activity occur";
  } else {
    var userCheckin = result.first[0];
    var passwordFromDb = result.first[3].toString();
    bool userPaidStatus = result.first[1];
    if (userPaidStatus == false) {
      return "You havent make payent, please made payment first before you checkin";
    }
    if (userCheckin) {
      return "You are checkin early, no need checkin twice";
    }
    {
      // Get the activity time from the database result and convert it to a DateTime object
      var activityDateTime = result.first[2];

      // Get the current date and time
      var now = DateTime.now();

      // Create a DateTime object for the start of the check-in window
      var checkinStart = DateTime(
        activityDateTime.year,
        activityDateTime.month,
        activityDateTime.day,
        activityDateTime.hour,
        activityDateTime.minute - 30,
      );

      // Create a DateTime object for the end of the check-in window
      var checkinEnd = DateTime(
        activityDateTime.year,
        activityDateTime.month,
        activityDateTime.day,
        activityDateTime.hour,
        activityDateTime.minute + 10,
      );

      // Check if the current time is within the check-in window
      if (password == passwordFromDb) {
        if (now.isAfter(checkinStart) && now.isBefore(checkinEnd)) {
          // Update member_checkin in activity_member to true
          await connection.execute(
            'UPDATE activity_member SET member_checkin = true WHERE user_id = @userId AND activity_id = @activityId',
            substitutionValues: {
              'userId': userId,
              'activityId': activity.activityId
            },
          );
          return "succesful checkin";
        } else {
          return "you are too early or too late to join activity";
        }
      } else {
        return "the password is wrong, please contact the organiser";
      }
    }
  }
}

Future<String> checkOut(int userId, ActivityInfo activity,
    PostgreSQLConnection connection, String checkoutPassword) async {
  // Retrieve the status of member_checkin

  var result = await connection.query(
    'SELECT am.member_checkin,al.checkout_password FROM activity_member AS am JOIN activity_list AS al ON am.activity_id = al.activity_id where am.user_id =@userId AND am.activity_id=@activityId',
    substitutionValues: {'userId': userId, 'activityId': activity.activityId},
  );

  if (result.isEmpty) {
    return "you have no join the activity";
  } else {
    var userCheckin = result.first[0];
    var checkoutPasswordFromDb = result.first[1];
    if (userCheckin && checkoutPasswordFromDb == checkoutPassword) {
      await connection.execute(
        'UPDATE activity_member SET member_checkout = true WHERE user_id = @userId AND activity_id=@activityId',
        substitutionValues: {
          'userId': userId,
          'activityId': activity.activityId
        },
      );
      return "checkout succesful";
    } else if (!userCheckin) {
      return "you have no checkin yet";
    } else if (userCheckin && checkoutPasswordFromDb != checkoutPassword) {
      return "checkout password error, please contact the organiser";
    }
  }
  return "something error, please inform the organiser or guide if any issue";
}
