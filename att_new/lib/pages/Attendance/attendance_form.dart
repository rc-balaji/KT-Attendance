import 'package:att_new/services/services.dart';
import 'package:flutter/material.dart';

class AttendanceForm extends StatelessWidget {
  final String? id;
  final String date = getCurrentDate();
  final String day = getCurrentDayOfWeek();
  final String time = getCurrentTime();
  final List<String> durations;
  final String? selectedDuration;
  // final TextEditingController commentsController;
  final VoidCallback onSubmit;
  final ValueChanged<String?> onDurationChanged;

  AttendanceForm({
    required this.id,
    required this.durations,
    required this.selectedDuration,
    // required this.commentsController,
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
            // SizedBox(height: 20),
            // TextFormField(
            //   controller: commentsController,
            //   decoration: InputDecoration(
            //     labelText: 'Comments (optional)',
            //     border: OutlineInputBorder(),
            //   ),
            //   maxLines: 3,
            // ),

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
