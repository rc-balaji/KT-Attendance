import 'dart:convert';
import 'package:att_new/constants.dart';
import 'package:att_new/services/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  final String? id;

  AttendancePage({required this.id});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int status = 0; // Update this based on your logic
  // var server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000"; // Replace with your actual API URL

  String? selectedDuration;
  final List<String> durations = [
    'Full Day',
    'Half Day',
    'Leave'
  ]; // Example durations
  final TextEditingController commentsController = TextEditingController();

  @override
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 0:
        return AttendanceForm(
          id: widget.id,
          durations: durations,
          selectedDuration: selectedDuration,
          onSubmit: submitAttendance,
          onDurationChanged: (String? value) {
            setState(() {
              selectedDuration = value;
            });
          },
        );
      case 1:
        return FutureBuilder<Map<String, dynamic>>(
          future:
              getCurrentLocation(context), // Fetch location data asynchronously
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Show a loading indicator while waiting
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error: ${snapshot.error}')); // Show an error message if an error occurs
            } else if (snapshot.hasData) {
              // When data is fetched successfully
              return AttendanceData(
                id: widget.id,
                date: getCurrentDate(),
                day: getCurrentDayOfWeek(),
                time: getCurrentTime(),
                // Safely access the data
              );
            } else {
              return Center(
                  child: Text(
                      'No location data found.')); // Handle the case with no data
            }
          },
        );
      case 2:
        return EndOfSessionText();
      default:
        return InvalidStatus();
    }
  }

  Future<void> submitAttendance() async {
    final String date = getCurrentDate();
    final String day = getCurrentDayOfWeek();
    final String time = getCurrentTime();
    final Map<String, dynamic> locationData =
        await getCurrentLocation(context); // Implement this
    print(locationData);
    final response = await http.post(
      Uri.parse('$api/add-attendance'), // Replace with your API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': widget.id,
        'date': date,
        'day': day,
        'time': time,
        'duration': selectedDuration ?? 'Full Day',
        'comments': commentsController.text,
        'locationData': locationData,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance submitted successfully!')),
      );
      // Handle successful submission, maybe change status to 1
      setState(() {
        status = 1; // Or whatever logic you have to update the status
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance.')),
      );
    }
  }
}

class AttendanceForm extends StatelessWidget {
  final String? id;
  final String date = getCurrentDate();
  final String day = getCurrentDayOfWeek();
  final String time = getCurrentTime();
  final List<String> durations;
  final String? selectedDuration;
  final VoidCallback onSubmit;
  final ValueChanged<String?> onDurationChanged;

  AttendanceForm({
    required this.id,
    required this.durations,
    required this.selectedDuration,
    required this.onSubmit,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: $date', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Day: $day', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Time: $time', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Type',
                border: OutlineInputBorder(),
              ),
              value: selectedDuration,
              items: durations.map((String duration) {
                return DropdownMenuItem<String>(
                  value: duration,
                  child: Text(duration),
                );
              }).toList(),
              onChanged: onDurationChanged,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text("Submit Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceData extends StatelessWidget {
  final String? id;
  final String date;
  final String day;
  final String time;

  var server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000"; // Replace with your actual API URL

  AttendanceData({
    required this.id,
    required this.date,
    required this.day,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: $date', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Day: $day', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Time: $time', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => logout(context), // Call the logout function
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set button color
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    Map<String, dynamic> location = await getCurrentLocation(context);

    final response = await http.post(
      Uri.parse('$api/logout-attendance'), // Replace with your server URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "id": id,
        "date": date,
        "time": time,
        "locationData": location
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout successful!')),
        );
        Navigator.of(context).pop(); // Navigate back after logout
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout Failed')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.reasonPhrase}')),
      );
    }
  }
}

class EndOfSessionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("End of Session"),
      ),
      body: Center(
        child: Text(
          'End of Session',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class InvalidStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invalid Status"),
      ),
      body: Center(
        child: Text(
          'Invalid status',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
