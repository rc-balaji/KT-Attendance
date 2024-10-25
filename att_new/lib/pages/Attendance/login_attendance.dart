import 'package:att_new/constants.dart';
import 'package:att_new/global/global_state.dart';
import 'package:att_new/services/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'attendance_form.dart';
import '../../widgets/loading_widget.dart';
import 'already_logged_in_widget.dart';

class LoginAttendancePage extends StatefulWidget {
  final String? id;
  LoginAttendancePage({required this.id});

  @override
  _LoginAttendancePageState createState() => _LoginAttendancePageState();
}

class _LoginAttendancePageState extends State<LoginAttendancePage> {
  String? _selectedDuration;
  bool _isLoggedInToday = false; // To track if the user has logged in today
  bool _isLoading = true; // To show a loader until the status is checked
  final List<String> _durations = ["Full Day", "Half Day", "Leave"];
  final TextEditingController _commentsController = TextEditingController();

  Map<String, dynamic>? _loginData;

  // var server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000"; // Replace with your actual server IP

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Check if logged in today
  }

  Future<void> checkLoginStatus() async {
    final String date = getCurrentDate();

    try {
      final response = await http.post(
        Uri.parse('$api/get-status'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          'id': widget.id,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Already Login')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No Login Found')),
          );
        }
        setState(() {
          _isLoggedInToday = result['success']; // Set the login status
          // _logintime = result['']
          _loginData = result['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to check login status');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking login status')),
      );
    }
  }

  Future<void> submitAttendance() async {
    // String id = ;
    final String date = getCurrentDate();
    final String day = getCurrentDayOfWeek();
    final String time = getCurrentTime();
    final Map<String, dynamic> locationData = await getCurrentLocation(context);

    final response = await http.post(
      Uri.parse('$api/add-attendance'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': widget.id,
        'date': date,
        'day': day,
        'time': time,
        'duration': _selectedDuration ?? 'Full Day',
        'comments': _commentsController.text,
        'locationData': locationData
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance submitted successfully!')),
      );
      Navigator.pop(context); // Navigate back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<GlobalState>(context);

    if (_isLoading) {
      return LoadingWidget(); // Show loading widget
    }

    if (_isLoggedInToday) {
      return AlreadyLoggedInWidget(
          id: widget.id,
          login_data: this._loginData); // Show already logged in widget
    }

    return AttendanceForm(
      id: widget.id,
      durations: _durations,
      selectedDuration: _selectedDuration,
      // commentsController: _commentsController,
      onSubmit: submitAttendance,
      onDurationChanged: (newDuration) {
        setState(() {
          _selectedDuration = newDuration;
        });
      },
    );
  }
}
