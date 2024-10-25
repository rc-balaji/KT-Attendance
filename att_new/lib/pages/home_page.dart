import 'package:att_new/pages/Attendance/attendance_service.dart';
import 'package:att_new/pages/Attendance/attendance_tab.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login/login_app.dart';
import 'Attendance/login_attendance.dart';
import '../global/global_state.dart'; // Import the global state
import '../services/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _opacity = 0.0; // Opacity for fade-in effect

  @override
  void initState() {
    super.initState();
    _animateGreeting();
  }

  // Method to animate greeting opacity
  void _animateGreeting() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade-in effect after 500ms
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access global state
    final globalState = Provider.of<GlobalState>(context);

    Future<void> logout(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data

      globalState.clearUser(); // Clear global state

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginApp()),
      );
    }

    // Method to show current location, date, time, and day
    void showInfo(BuildContext context) async {
      Map<String, dynamic> locationData = await getCurrentLocation(context);
      String locationStatus = locationData['status'];
      String locationInfo;

      if (locationData['latitude'] != null &&
          locationData['longitude'] != null) {
        locationInfo =
            'Lat: ${locationData['latitude']}, Long: ${locationData['longitude']}';
      } else {
        locationInfo = locationStatus; // Show status message if no location
      }

      String date = getCurrentDate();
      String time = getCurrentTime();
      String day = getCurrentDayOfWeek();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Current Info"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Location: $locationInfo"),
                  Text("Date: $date"),
                  Text("Time: $time"),
                  Text("Day: $day"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }

    // Method to navigate to the LoginAttendancePage
    void navigateToAttendance(BuildContext context) async {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AttendanceTab(
            id: globalState.id,
          ),
        ),
      );
    }

    Future<void> _checkLocationStatus(String pagesName) async {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enable location services'),
          action: SnackBarAction(
            label: 'Enable',
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ));
      } else {
        if (pagesName == "show")
          showInfo(context);
        else
          navigateToAttendance(context);
      }
    }

    // Method to get the greeting based on the current time
    String getGreeting() {
      final hour = DateTime.now().hour; // Get the current hour

      if (hour < 12) {
        return 'Good Morning ☕';
      } else if (hour < 17) {
        return 'Good Afternoon ☀️';
      } else if (hour < 21) {
        return 'Good Evening 🌃';
      } else {
        return 'Good Night 🌙';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${globalState.name}'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('${globalState.name}'),
              accountEmail: Text('${globalState.email}'),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
                backgroundColor: Colors.white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Show Current Info'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _checkLocationStatus("show"); // Show current info dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Attendance'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _checkLocationStatus("Attendance");
                // Navigate to attendance page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                logout(context); // Logout the user
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Improved greeting with opacity animation and stylish box
            AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1), // Duration for fade-in effect
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  getGreeting(), // Display the greeting based on the time
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Add the Lottie animation below the greeting
            Lottie.asset('assets/lottie/home.json', width: 450, height: 450),
            SizedBox(height: 20),
            // Optional: Add a motivational quote or message below
            Text(
              'Hope you have a great day!',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
