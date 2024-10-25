import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Attendance")),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
