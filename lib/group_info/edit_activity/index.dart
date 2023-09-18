import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

import '../../Home/search_group_list/data.dart';
import '../../query.dart';
import '../group_activity_list/activity_info/data.dart';
import '../group_activity_list/activity_info/index.dart';
import '../location/index.dart';
import 'package:latlong2/latlong.dart' as latLng;

class EditActivityPage extends StatefulWidget {
  final PostgreSQLConnection connection;
  final InfoItem selectedGroup;
  final User user;

  final ActivityInfo activityData;

  const EditActivityPage(
      {Key? key,
      required this.connection,
      required this.activityData,
      required this.user,
      required this.selectedGroup})
      : super(key: key);

  @override
  _EditActivityState createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivityPage> {
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

  void editActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Convert latitude and longitude to a string
        String locationString = '$_latitude,$_longitude';
        await widget.connection.query(
            "UPDATE activity_list SET location=@location, activity_name=@activityName, description=@description, permit=@permit, checkin_password=@checkinPassword, payment=@payment, map_url=@mapUrl, image_url=@imageUrl, date=@dateOfActivity WHERE activity_id=@id",
            substitutionValues: {
              "location": locationString,
              "activityName": _activityName,
              "description": _description,
              "permit": _permit,
              "checkinPassword": _checkinPassword,
              "checkoutPassword": _checkoutPassword,
              "payment": _payment,
              "mapUrl": "https://penanghill.gov.my/hikingtrails/",
              "imageUrl":
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShSIcyVGoG4cmg6LqljZ064XZiQM6xk_i4EA&usqp=CAU",
              "dateOfActivity": _dateTimeOfActivity,
              "id": widget.activityData.activityId,
            });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Activity $_activityName registered successfully")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        print(e);
      }
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityPage(
              activityId: widget.activityData.activityId,
              connection: widget.connection,
              haveJoin: true,
              selectedGroup: widget.selectedGroup,
              user: widget.user,
            ),
          ));
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the values with activityData
    _activityName = widget.activityData.activityName;
    _location = widget.activityData.latLong;
    final locationValues = _location.split(',');
    _latitude = locationValues[0];
    _longitude = locationValues[1];
    _locationController.text = '$_latitude, $_longitude';
    _description = widget.activityData.description;
    _permit = widget.activityData.requirePermitBool;
    _checkinPassword = widget.activityData.checkinPassword;
    _checkoutPassword = widget.activityData.checkoutPassword;
    _payment = widget.activityData.payment;
    _dateTimeOfActivity = widget.activityData.dateTime;
    _dateOfActivityControllerr.text = _dateTimeOfActivity != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(_dateTimeOfActivity!)
        : '';
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
    if (widget.activityData.requirePermitBool == false) {
      //noting happen
    } else {
      _permit == true;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Activity Detail "),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  //I want the below all of the TextFormField have a preset data first, example if tthe activityData.activityName is "Penang Hiking", then should show the "penang Hiking" that an be show and editable
                  TextFormField(
                    decoration: InputDecoration(labelText: "Activity Name"),
                    initialValue: widget.activityData.activityName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a activity name";
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
                    initialValue: widget.activityData.description,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter some word explain this activity";
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
                    decoration: InputDecoration(labelText: "Password"),
                    initialValue: widget.activityData.checkinPassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a checkin password";
                      }
                      return null;
                    },
                    onSaved: (value) => _checkinPassword = value!,
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Checkout Password"),
                    initialValue: widget.activityData.checkoutPassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a checkout password";
                      }
                      return null;
                    },
                    onSaved: (value) => _checkoutPassword = value!,
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: "Payment (RM) per person"),
                    initialValue: widget.activityData.payment.toString(),
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
                    controller: TextEditingController(
                      text: _dateTimeOfActivity != null
                          ? DateFormat('yyyy-MM-dd hh:mm a')
                              .format(_dateTimeOfActivity!)
                          : '',
                    ),
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
                    onPressed: editActivity,
                    child: Text('Save'),
                  )
                ]))));
  }
}
