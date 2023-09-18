import 'package:flutter/material.dart';
import 'package:hiking_platform/group_info/group_activity_list/activity_info/attendence/data.dart';
import 'package:hiking_platform/group_info/group_activity_list/activity_info/data.dart';
import 'package:postgres/postgres.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geolocator/geolocator.dart';

class Attendance extends StatefulWidget {
  final ActivityInfo activity;
  final int userId;
  final PostgreSQLConnection connection;
  final int groupId;

  const Attendance({
    Key? key,
    required this.activity,
    required this.userId,
    required this.connection,
    required this.groupId,
  }) : super(key: key);

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late String _checkinPassword;
  late String _checkoutPassword;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    startConnectivityMonitoring(context, widget.activity.activityId,
        widget.userId, await getCurrentGPS());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Checking Attendance",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Checking Attendance"),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: () async {
                      await _showCheckinPasswordDialog(context);
                      String checkInResult = await checkIn(widget.userId,
                          widget.activity, widget.connection, _checkinPassword);

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Mark Checkin'),
                            content: Text(checkInResult),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Mark Checkin"),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () async {
                      // decline action
                      await _showCheckoutPasswordDialog(context);
                      String checkoutResult = await checkOut(
                          widget.userId,
                          widget.activity,
                          widget.connection,
                          _checkoutPassword);

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Mark Checkout'),
                            content: Text(checkoutResult),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Mark Checkout"),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: () async {
                      // decline action
                      String currentGPS = await getCurrentGPS();

                      String submitResult = await submitGPS(widget.userId,
                          widget.activity, widget.connection, currentGPS);

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Submit GPS'),
                            content: Text(submitResult),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Submit GPS"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _showCheckinPasswordDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Checkin Password'),
          content: TextField(
            onChanged: (value) {
              _checkinPassword = value;
            },
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCheckoutPasswordDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Checkout Password'),
          content: TextField(
            onChanged: (value) {
              _checkoutPassword = value;
            },
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Future<String> getCurrentGPS() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are disabled, handle the case accordingly
    // For example, show an error message or prompt the user to enable location services
    throw 'Location services are disabled.';
  }

  // Check for location permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    // Location permission is permanently denied, handle the case accordingly
    // For example, show an error message or prompt the user to grant location permission
    throw 'Location permission is permanently denied.';
  }

  if (permission == LocationPermission.denied) {
    // Location permission is denied, request permission from the user
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      // Location permission was not granted, handle the case accordingly
      // For example, show an error message or prompt the user to grant location permission
      throw 'Location permission was not granted.';
    }
  }

  // Get the current position
  Position position = await Geolocator.getCurrentPosition();

  // Create a LatLng object from the position
  latLng.LatLng currentLocation =
      latLng.LatLng(position.latitude, position.longitude);

  String locationValue =
      "${currentLocation.latitude},${currentLocation.longitude}";

  return locationValue;
}

Future<String> submitGPS(int userId, ActivityInfo activity,
    PostgreSQLConnection connection, String gps) async {
  // Retrieve the check-in status of the user
  bool isConnected = await checkInternetConnectivity();
  if (isConnected) {
    var result = await connection.query(
      'SELECT member_checkin FROM activity_member WHERE user_id = @userId AND activity_id = @activityId',
      substitutionValues: {'userId': userId, 'activityId': activity.activityId},
    );

    if (result.isEmpty) {
      return "You have not joined the activity";
    } else {
      var userCheckin = result.first[0];
      if (!userCheckin) {
        return "You have not checked in yet. Please check in before submitting your GPS location.";
      }

      //subbmit user gps
      await connection.query(
          "UPDATE activity_member SET submit_gps=@location WHERE activity_id=@activityId AND user_id=@userId",
          substitutionValues: {
            "location": gps,
            "userId": userId,
            "activityId": activity.activityId
          });

      return "you have submit your current location";
    }
  } else {
    // Save GPS location locally
    await saveLocationLocally(activity.activityId, userId, gps);
    return "No internet connection. GPS location saved locally.";
  }
}

Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> saveLocationLocally(
    int activityId, int userId, String location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('savedLocation', location);
}

void startConnectivityMonitoring(
    BuildContext context, int activityId, int userId, String location) {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      synchronizeData(context, activityId, userId, location);
    }
  });
}

Future<void> synchronizeData(
    BuildContext context, int activityId, int userId, String location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLocation = prefs.getString('savedLocation');

  if (savedLocation != null) {
    PostgreSQLConnection connection = PostgreSQLConnection(
      '10.112.53.35',
      // '192.168.100.17',
      5432,
      'postgres',
      username: 'postgres',
      password: '1234',
    );

    try {
      await connection.open();

      await connection.query(
        "UPDATE activity_member SET submit_gps = @location WHERE user_id = @userId AND activity_id = @activityId",
        substitutionValues: {
          "location": location,
          "userId": userId,
          "activityId": activityId,
        },
      );

      // Clear the locally saved location
      await prefs.remove('savedLocation');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Submit GPS'),
            content: Text("GPS location submitted successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle the error, such as logging it or displaying a message
      print('Error updating the database: $e');
    } finally {
      await connection.close();
    }
  }
}
