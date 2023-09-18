import 'package:postgres/postgres.dart';

Future<bool> topUp(
    int userId, double topUp, PostgreSQLConnection connection) async {
  // Retrieve user
  List<List<dynamic>> results = await connection.query(
    'SELECT user_id, balance FROM \"user\" WHERE user_id = @userId',
    substitutionValues: {'userId': userId},
  );

  // If the user balance value is null, set it to 0.00 as default

  double userBalance = 0.00;

  if (results.isNotEmpty) {
    userBalance = results.first[1] == null ? 0.00 : results.first[1];
  }

  await connection.query(
    "UPDATE \"user\" SET balance = @topUp "
    "WHERE user_id = @userId",
    substitutionValues: {
      "topUp": userBalance + topUp,
      "userId": userId,
    },
  );

  return true;
}
