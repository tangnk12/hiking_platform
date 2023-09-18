import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';

class LocationSelectionPage extends StatefulWidget {
  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  latLng.LatLng _currentLocation =
      latLng.LatLng(0, 0); // Updated variable for current location
  String _searchQuery = ''; // Added variable for search query

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    } else {
      print('Location permission denied.');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = latLng.LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _handleSearch(String locationName) async {
    try {
      final locationResults = await locationFromAddress(locationName);
      if (locationResults.isNotEmpty) {
        final location = locationResults.first;
        final coordinates =
            latLng.LatLng(location.latitude, location.longitude);
        setState(() {
          _currentLocation = coordinates;
        });
      }
    } catch (e) {
      print('Error searching for location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Activity Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                _handleSearch(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _handleSearch(_searchQuery);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              key: ValueKey(_currentLocation), // Add key to FlutterMap widget
              options: MapOptions(
                center: _currentLocation,
                zoom: 13.0,
                onTap: (tapPosition, point) {
                  Navigator.pop(context, point);
                },
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/tangnk/clhw3qasu008z01pnbb8726ll/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGFuZ25rIiwiYSI6ImNsaHZ5eTZzYjBja28zc3BhNGI5Z2xhMmgifQ.DryaHvjolIn34FnB0ol-2w',
                  additionalOptions: {
                    'mapStyleId': "clhw3qasu008z01pnbb8726ll",
                    'accessToken':
                        "sk.eyJ1IjoidGFuZ25rIiwiYSI6ImNsaHczZGIxMDBnMmUzbGxiNWp1ZGZwMnAifQ.OkkJ8lP1nEIn-SmZHsvVgQ", // Map style ID
                  },
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation,
                      builder: (ctx) => Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
