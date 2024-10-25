import 'package:att_new/constants.dart';
import 'package:att_new/services/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/attendance_login.dart';
import 'pages/attendance_logout.dart';
import 'pages/attendance_history.dart';

class AttendanceTab extends StatefulWidget {
  final String? id;

  AttendanceTab({required this.id});

  @override
  _AttendanceTabState createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  int _selectedIndex = 0;
  // var server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000"; // Replace with your actual API URL
  Map<String, dynamic> apiData = {}; // Store data from the API request
  bool isLoading = true; // Loading indicator
  String date = getCurrentDate();
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.onlyShowSelected;

  // AppBar titles based on selected tab index
  List<String> _appBarTitles = [
    'Attendance Login',
    'Attendance Logout',
    'Attendance History',
  ];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data on initialization
  }

  // Fetch data from the API
  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse('$api/get-status'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.id,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          apiData = jsonDecode(response.body); // Store the API response

          print("API DATA-------");
          print(apiData);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Change the current page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Reset the widget by resetting the selected index and fetching data again
  void _resetWidget() {
    setState(() {
      _selectedIndex = 0; // Reset to the first tab (Login)
      isLoading = true; // Show loading spinner again
      fetchData(); // Re-fetch data
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      AttendanceLoginPage(
          apiData: apiData,
          id: widget.id,
          reset: _resetWidget), // Implement this page properly
      AttendanceLogoutPage(
        apiData: apiData,
        id: widget.id,
      ), // Implement this page properly
      AttendanceHistoryPage(
        id: widget.id,
      ), // Implement this page properly
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]), // Dynamic AppBar title
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Reset button
            onPressed: _resetWidget, // Call the reset function
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading spinner while fetching data
            : _pages[_selectedIndex], // Display the currently selected page
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: labelBehavior,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          _onItemTapped(index); // Change selected tab
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.login),
            selectedIcon: Icon(Icons.login, color: Colors.blue),
            label: 'Login',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout),
            selectedIcon: Icon(Icons.logout, color: Colors.blue),
            label: 'Logout',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history, color: Colors.blue),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
