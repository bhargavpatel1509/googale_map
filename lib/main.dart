import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(LocationTrackerApp());
}

class LocationTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationTrackerScreen(),
    );
  }
}

class LocationTrackerScreen extends StatefulWidget {
  @override
  _LocationTrackerScreenState createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LocationData? locationData;
  bool a = true;
  @override
  void initState() {
    super.initState();
    //_onMapCreated(_controller!);
  }

  Future<void> _startLocationTracking() async {
    Location location = Location();
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 10000);

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      locationData = currentLocation;

      if (_controller != null) {
        setState(() {
          a = false;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId('current_location'),
              position: LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              ),
            ),
          );
          _controller!.animateCamera(CameraUpdate.newLatLng(
              LatLng(locationData!.latitude!, locationData!.longitude!)));
          print(locationData!.latitude);
          print(locationData!.longitude);
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracker'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller = controller;
          _startLocationTracking();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 15.0,
        ),
        markers: _markers,
      ),
    );
  }
}
