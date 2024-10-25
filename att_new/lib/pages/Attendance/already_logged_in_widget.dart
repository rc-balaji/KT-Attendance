import 'dart:convert';

import 'package:att_new/constants.dart';
import 'package:flutter/material.dart';
import '../../services/services.dart';
import 'package:http/http.dart' as http;

class AlreadyLoggedInWidget extends StatelessWidget {
  final String? id;
  final Map<String, dynamic>? login_data;

  AlreadyLoggedInWidget({required this.id, required this.login_data});

  @override
  Widget build(BuildContext context) {
    // var server_ip = SERVER_IP;

    String api = "http://${SERVER_IP}:3000";

    String date = getCurrentDate();

    String time = getCurrentTime();

    Future<void> logout(BuildContext context) async {
      // SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> location = await getCurrentLocation(context);

      final response = await http.post(
        Uri.parse('$api/logout-attendance'), // Use your server URL
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
        // Parse the response body
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success']) {
          print("Success");
          // await prefs.clear(); // Clear all stored data

          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logout Failed'),
          ));
        }
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${response.reasonPhrase}'),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Already Logged In")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Handle Logout or display message
            logout(context);
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}
