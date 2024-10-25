import 'package:flutter/material.dart';

class AttendanceDetailPage extends StatelessWidget {
  final dynamic record;

  AttendanceDetailPage({required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${record['date']}", style: TextStyle(fontSize: 20)),
            Text("Duration: ${record['duration']}",
                style: TextStyle(fontSize: 18)),
            Text("Login Time: ${record['login_time']}",
                style: TextStyle(fontSize: 18)),
            Text("Logout Time: ${record['logout_time'] ?? "Not logged out"}",
                style: TextStyle(fontSize: 18)),
            Text(
                "Login Location: Lat: ${record['login_location']['lat']}, Long: ${record['login_location']['long']}",
                style: TextStyle(fontSize: 18)),
            if (record['logout_location'] != null) ...[
              Text(
                  "Logout Location: Lat: ${record['logout_location']['lat']}, Long: ${record['logout_location']['long']}",
                  style: TextStyle(fontSize: 18)),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
