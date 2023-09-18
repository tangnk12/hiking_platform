import 'package:flutter/material.dart';
import 'package:hiking_platform/group_info/create_activity/data.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

import '../../Home/search_group_list/data.dart';
import '../../query.dart';
import '../group_activity_list/activity_info/data.dart';
import '../index.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../location/index.dart';

class CreateActivityPage extends StatefulWidget {
  final PostgreSQLConnection connection;
  final InfoItem curGroup;
  final User user;

  const CreateActivityPage({
    Key? key,
    required this.connection,
    required this.curGroup,
    required this.user,
  }) : super(key: key);

  @override
  _CreateActivityState createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late String _activityName,
      _location,
      _description,
      _checkinPassword,
      _checkoutPassword,
      _latitude,
      _longitude,
      imageUrl;
  DateTime? _dateTimeOfActivity;

  bool _permit = false;
  late double _payment;
  final TextEditingController _dateOfActivityControllerr =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void saveActivityToDatabase() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Convert latitude and longitude to a string
        String locationString = '$_latitude,$_longitude';

        await widget.connection.query(
          "INSERT INTO activity_list (organiser_id, location, activity_name, description, permit, checkin_password, checkout_password, payment, map_url, group_id, image_url, date) VALUES (@organiserId, @location, @activityName, @description, @permit, @checkinPassword, @checkoutPassword, @payment, @mapUrl, ${widget.curGroup.id}, @imageUrl, @dateOfActivity)",
          substitutionValues: {
            "organiserId": widget.user.userId,
            "location": locationString,
            "activityName": _activityName,
            "description": _description,
            "permit": _permit,
            "checkinPassword": _checkinPassword,
            "checkoutPassword": _checkoutPassword,
            "payment": _payment,
            "mapUrl": "https://penanghill.gov.my/hikingtrails/",
            "groupId": widget.curGroup.id,
            "imageUrl":
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShSIcyVGoG4cmg6LqljZ064XZiQM6xk_i4EA&usqp=CAU",
            "dateOfActivity": _dateTimeOfActivity,
          },
        );

        int createdActivityId = await getCreateActivity(
          widget.user.userId,
          _activityName,
          widget.curGroup,
          widget.connection,
        );

        joinActivity(
          widget.user,
          widget.curGroup.id,
          createdActivityId,
          widget.connection,
          "organiser",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Activity $_activityName registered successfully"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupInfo(
            user: widget.user,
            selectedGroup: widget.curGroup,
            connection: widget.connection,
          ),
        ),
      );
    }
  }

  void _selectLocation() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionPage(),
      ),
    );

    if (selectedLocation != null && selectedLocation is latLng.LatLng) {
      setState(() {
        _latitude = selectedLocation.latitude.toString();
        _longitude = selectedLocation.longitude.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Activity"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Activity Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an activity name";
                  }
                  return null;
                },
                onSaved: (value) => _activityName = value!,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a location";
                  }
                  return null;
                },
                onSaved: (value) => _location = value!,
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationSelectionPage(),
                    ),
                  );

                  if (selectedLocation != null &&
                      selectedLocation is latLng.LatLng) {
                    setState(() {
                      _latitude = selectedLocation.latitude.toString();
                      _longitude = selectedLocation.longitude.toString();
                      _locationController.text =
                          '$_latitude, $_longitude'; // Update location text field
                    });
                  } else {
                    // Handle case when no location is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a location")),
                    );
                  }
                },
                child: Text('Select Location'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              SwitchListTile(
                title: Text("Permit?"),
                value: _permit,
                onChanged: (bool value) {
                  setState(() {
                    _permit = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Check-in Password"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a check-in password";
                  }
                  return null;
                },
                onSaved: (value) => _checkinPassword = value!,
                obscureText: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Check-out Password"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a check-out password";
                  }
                  return null;
                },
                onSaved: (value) => _checkoutPassword = value!,
                obscureText: true,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: "Payment (RM) per person"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an amount";
                  }
                  return null;
                },
                onSaved: (value) => _payment = double.parse(value!),
              ),
              TextFormField(
                controller: _dateOfActivityControllerr,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Activity',
                  errorStyle: TextStyle(height: 0),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateTimeOfActivity ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          _dateTimeOfActivity ?? DateTime.now()),
                    );
                    setState(() {
                      _dateTimeOfActivity = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time?.hour ?? 0,
                        time?.minute ?? 0,
                      );
                      _dateOfActivityControllerr.text =
                          DateFormat('yyyy-MM-dd hh:mm a')
                              .format(_dateTimeOfActivity!);
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: saveActivityToDatabase,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
