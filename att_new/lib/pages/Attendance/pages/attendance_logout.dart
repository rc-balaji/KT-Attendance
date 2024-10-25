import 'dart:async';
import 'dart:convert';
import 'package:att_new/constants.dart';
import 'package:att_new/services/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendanceLogoutPage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic> apiData;

  AttendanceLogoutPage({required this.id, required this.apiData});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendanceLogoutPage> {
  late int status; // Update this based on your logic
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
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      status = widget.apiData['status'];
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 0:
        return AttendanceForm(
          message: 'Please Login',
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
                apiData: widget.apiData,
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
  final String message;

  AttendanceForm({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AttendanceData extends StatefulWidget {
  final String? id;
  final Map<String, dynamic> apiData;

  AttendanceData({required this.id, required this.apiData});

  @override
  _AttendanceDataState createState() => _AttendanceDataState();
}

class _AttendanceDataState extends State<AttendanceData> {
  // var server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000"; // Replace with your actual API URL
  Duration workingDuration = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    calculateWorkingHours();
    startTimer(); // Start the timer to update the working duration every second
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        calculateWorkingHours(); // Update the working hours every second
      });
    });
  }

  void calculateWorkingHours() {
    String loginTimeStr = widget.apiData['data']['login_time'];
    DateTime loginTime = _parseTime(loginTimeStr);
    DateTime currentTime = DateTime.now();

    setState(() {
      workingDuration = currentTime.difference(loginTime);
    });
  }

  DateTime _parseTime(String timeStr) {
    List<String> parts = timeStr.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    int second = int.parse(parts[2]);

    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDetailRow("Date", widget.apiData['data']['date']),
                    // _buildDetailRow("Day", widget.apiData['data']['day']),
                    _buildDetailRow("Current Time", getCurrentTime()),
                    // _buildDetailRow(
                    //     "Type ", widget.apiData['data']['duration']),
                    _buildDetailRow(
                        "Total Duration", formatDuration(workingDuration)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => logout(context),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    Map<String, dynamic> location = await getCurrentLocation(context);

    final response = await http.post(
      Uri.parse('$api/logout-attendance'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "id": widget.id,
        "date": widget.apiData['data']['date'],
        "time": getCurrentTime(),
        "locationData": location,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout successful!')),
        );
        Navigator.of(context).pop();
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
