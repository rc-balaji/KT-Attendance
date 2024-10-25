import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:att_new/services/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';

class AttendanceLoginPage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic> apiData;
  final Function reset;

  AttendanceLoginPage(
      {required this.id, required this.apiData, required this.reset});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendanceLoginPage> {
  late int status; // Update this based on your logic

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
          id: widget.id,
          durations: durations,
          selectedDuration: selectedDuration,
          reset: widget.reset,
          // onSubmit: submitAttendance,
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
}

class AttendanceForm extends StatelessWidget {
  final String? id;
  final String date = getCurrentDate();
  final String day = getCurrentDayOfWeek();
  final String time = getCurrentTime();
  final List<String> durations;
  final String? selectedDuration;
  final Function reset;

  // final VoidCallback onSubmit;
  final ValueChanged<String?> onDurationChanged;

  AttendanceForm({
    required this.id,
    required this.durations,
    required this.selectedDuration,
    required this.reset,
    // required this.onSubmit,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    var server_ip = SERVER_IP;

    String api = "http://${server_ip}:3000"; // Replace with your actual API URL

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
          'id': id,
          'date': date,
          'day': day,
          'time': time,
          'duration': selectedDuration ?? 'Full Day',
          // 'comments': commentsController.text,
          'locationData': locationData,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted successfully!')),
        );
        print("23");
        sleep(Duration(seconds: 3));
        print("26");
        reset();
        // Handle successful submission, maybe change status to 1
        // setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit attendance.')),
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(),
              SizedBox(height: 20),
              _buildDetailsCard(),
              SizedBox(height: 20),
              _buildDurationDropdown(),
              SizedBox(height: 30),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the title section with a styled intro message
  Widget _buildTitleSection() {
    return Row(
      children: [
        Icon(
          Icons.assignment_ind,
          size: 30,
          color: Colors.blueAccent,
        ),
        SizedBox(width: 10),
        Text(
          "Add Your Attendance",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  // Method to build the card that displays the ID, Date, Day, and Time
  Widget _buildDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.blueAccent.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.account_circle, 'ID: ', id ?? 'N/A'),
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildDetailRow(Icons.date_range, 'Date: ', date),
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildDetailRow(Icons.calendar_today, 'Day: ', day),
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildDetailRow(Icons.access_time, 'Time: ', time),
          ],
        ),
      ),
    );
  }

  // Helper method to build individual detail rows inside the card
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the dropdown for selecting duration
  Widget _buildDurationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Duration',
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      value: selectedDuration,
      items: durations.map((String duration) {
        return DropdownMenuItem<String>(
          value: duration,
          child: Text(duration),
        );
      }).toList(),
      onChanged: onDurationChanged,
      dropdownColor: Colors.blue[50],
    );
  }

  Future<void> submitAttendance(BuildContext context) async {
    final String date = getCurrentDate(); // Get the current date
    final String day = getCurrentDayOfWeek(); // Get the current day
    final String time = getCurrentTime(); // Get the current time
    final Map<String, dynamic> locationData =
        await getCurrentLocation(context); // Fetch location data

    final String api =
        "http://${SERVER_IP}:3000"; // Replace with your actual server IP
    final String url = '$api/add-attendance'; // Replace with your API endpoint

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
          'date': date,
          'day': day,
          'time': time,
          'duration': selectedDuration ??
              'Full Day', // Use 'Full Day' as default if none is selected
          'locationData': locationData,
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted successfully!')),
        );

        await Future.delayed(Duration(
            seconds: 3)); // Optional delay for user to read the message
        reset(); // Reset form or handle navigation as needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit attendance. Please try again.')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Method to build the submit button with a nice style
  // Method to build the submit button with a nice style
  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await submitAttendance(
              context); // Call the submit function when the button is pressed
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Text(
          "Submit Attendance",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                      "Already Logged In",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDetailRow("Date", widget.apiData['data']['date']),
                    _buildDetailRow("Day", widget.apiData['data']['day']),
                    _buildDetailRow(
                        "Login Time", widget.apiData['data']['login_time']),
                    _buildDetailRow(
                        "Type ", widget.apiData['data']['duration']),
                    _buildDetailRow(
                        "Total Duration", formatDuration(workingDuration)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // Logout Button
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
