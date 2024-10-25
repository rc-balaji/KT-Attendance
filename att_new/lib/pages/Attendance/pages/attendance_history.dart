import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants.dart';
import 'attendance_detail_page.dart'; // Import the detail page

class AttendanceHistoryPage extends StatefulWidget {
  final String? id;

  AttendanceHistoryPage({required this.id});

  @override
  _AttendanceHistoryPageState createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  List<dynamic> attendanceRecords = [];
  String filter = 'all'; // Default filter
  DateTime selectedDate = DateTime.now();
  String? selectedYear;
  String? selectedMonth;
  int? selectedWeek;

  List<String> month = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"
  ];

  // final server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000"; // Replace with your API URL

  @override
  void initState() {
    super.initState();
    fetchAttendanceHistory();
  }

  Future<void> fetchAttendanceHistory() async {
    final response = await http.get(
      Uri.parse('$api/history/all/${widget.id}'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        var dataList = jsonResponse['data'];
        if (dataList.isNotEmpty && dataList[0]['attendence'] is List) {
          setState(() {
            attendanceRecords = dataList[0]['attendence'];
          });
        }
      }
    } else {
      throw Exception('Failed to load attendance history');
    }
  }

  // Method to filter data
  List<dynamic> getFilteredRecords() {
    DateTime startDate;
    DateTime endDate;

    switch (filter) {
      case 'day':
        startDate = selectedDate;
        endDate = selectedDate;
        break;
      case 'week':
        if (selectedYear == null ||
            selectedMonth == null ||
            selectedWeek == null) {
          return attendanceRecords; // Return all records if selection is incomplete
        }
        startDate = DateTime(
          int.parse(selectedYear!),
          int.parse(selectedMonth!),
          (selectedWeek! - 1) * 7 + 1,
        );
        endDate = startDate.add(Duration(days: 6));
        break;
      case 'month':
        if (selectedYear == null || selectedMonth == null) {
          return attendanceRecords; // Return all records if selection is incomplete
        }
        startDate =
            DateTime(int.parse(selectedYear!), int.parse(selectedMonth!), 1);
        endDate = DateTime(
            int.parse(selectedYear!), int.parse(selectedMonth!) + 1, 0);
        break;
      case 'year':
        if (selectedYear == null) {
          return attendanceRecords; // Return all records if selection is incomplete
        }
        startDate = DateTime(int.parse(selectedYear!), 1, 1);
        endDate = DateTime(int.parse(selectedYear!) + 1, 1, 0);
        break;
      default:
        return attendanceRecords; // No filtering, return all records
    }

    return attendanceRecords.where((record) {
      DateTime recordDate =
          DateTime.parse(record['date']); // Assuming 'date' is in ISO format
      return recordDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterAndCalendar(),
          Expanded(
            child: attendanceRecords.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: getFilteredRecords().length,
                      itemBuilder: (context, index) {
                        var record = getFilteredRecords()[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.calendar_today,
                                color: Colors.blueAccent),
                            title: Text(
                              record['date'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'Login Time: ${record['login_time'] ?? 'N/A'}\nDuration: ${record['duration'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.blueAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AttendanceDetailPage(record: record),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndCalendar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildFilterDropdown(),
          SizedBox(height: 10),
          if (filter == 'day') _buildDateSelector(),
          if (filter == 'week') _buildWeekSelector(),
          if (filter == 'month') _buildMonthSelector(),
          if (filter == 'year') _buildYearSelector(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: filter,
      items: <String>['all', 'day', 'week', 'month', 'year']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          filter = newValue!;
          // Reset selected values when filter changes
          selectedYear = null;
          selectedMonth = null;
          selectedWeek = null;
          selectedDate = DateTime.now(); // Reset date to today if needed
        });
      },
      underline: Container(height: 2, color: Colors.blueAccent),
    );
  }

  Widget _buildDateSelector() {
    return ElevatedButton(
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      child: Text("Select Date"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
    );
  }

  Widget _buildWeekSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildYearDropdown(),
        _buildMonthDropdown(),
        _buildWeekDropdown(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildYearDropdown(),
        _buildMonthDropdown(),
      ],
    );
  }

  Widget _buildYearSelector() {
    return _buildYearDropdown();
  }

  Widget _buildYearDropdown() {
    return DropdownButton<String>(
      value: selectedYear,
      hint: Text('Select Year'),
      items: List.generate(10, (index) {
        int year = DateTime.now().year - index;
        return DropdownMenuItem<String>(
          value: year.toString(),
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedYear = newValue;
        });
      },
      underline: Container(height: 1, color: Colors.blueAccent),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButton<String>(
      value: selectedMonth,
      hint: Text('Select Month'),
      items: List.generate(12, (index) {
        return DropdownMenuItem<String>(
          value: (index + 1).toString(),
          child: Text(month[index]),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedMonth = newValue;
        });
      },
      underline: Container(height: 1, color: Colors.blueAccent),
    );
  }

  Widget _buildWeekDropdown() {
    return DropdownButton<int>(
      value: selectedWeek,
      hint: Text('Select Week'),
      items: List.generate(5, (index) {
        return DropdownMenuItem<int>(
          value: index + 1,
          child: Text('${index + 1}'),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          selectedWeek = newValue;
        });
      },
      underline: Container(height: 1, color: Colors.blueAccent),
    );
  }
}
