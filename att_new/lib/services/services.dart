import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

Future<Map<String, dynamic>> getCurrentLocation(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;
  String statusMessage;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Show a dialog to ask the user to enable location services
    await _showLocationServiceDialog(context);
    return {
      'status': 'Location services are disabled.',
      'latitude': null,
      'longitude': null
    };
  }

  // Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      statusMessage = 'Location permissions are denied';
      return {'status': statusMessage, 'latitude': null, 'longitude': null};
    }
  }

  // If permission is denied forever, return the appropriate message
  if (permission == LocationPermission.deniedForever) {
    statusMessage = 'Location permissions are permanently denied';
    return {'status': statusMessage, 'latitude': null, 'longitude': null};
  }

  // If permissions are granted, get the current position
  try {
    Position position = await Geolocator.getCurrentPosition();
    return {
      'status': 'Location retrieved successfully',
      'latitude': position.latitude,
      'longitude': position.longitude
    };
  } catch (e) {
    // Handle exceptions
    return {
      'status': 'Error retrieving location: $e',
      'latitude': null,
      'longitude': null
    };
  }
}

Future<void> _showLocationServiceDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable location services to use this feature.'),
        actions: <Widget>[
          TextButton(
            child: Text('Settings'),
            onPressed: () {
              // You can use the 'openSettings()' method from the Geolocator package
              Geolocator.openLocationSettings();
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

// Get the current date
String getCurrentDate() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

// Get the current time
String getCurrentTime() {
  return DateFormat('HH:mm:ss').format(DateTime.now());
}

// Get the current day of the week
String getCurrentDayOfWeek() {
  return DateFormat('EEEE').format(DateTime.now());
}
