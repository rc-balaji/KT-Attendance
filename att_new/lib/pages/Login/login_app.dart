import 'package:att_new/constants.dart';
import 'package:att_new/global/global_state.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../home_page.dart'; // Import your HomePage here

class LoginApp extends StatefulWidget {
  @override
  _LoginAppState createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isOffline = false; // Track offline status

  var server_ip = SERVER_IP;

  String api = "http://${SERVER_IP}:3000";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isOffline = true;
      });
    } else {
      setState(() {
        _isOffline = false;
      });
    }
  }

  Future<void> _checkLocationStatus() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enable location services'),
        action: SnackBarAction(
          label: 'Enable',
          onPressed: () {
            Geolocator.openLocationSettings();
          },
        ),
      ));
    }
  }

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    await _checkNetworkStatus(); // Check network before login
    if (_isOffline) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No internet connection. Please try again.'),
      ));
      return;
    }

    final globalState = Provider.of<GlobalState>(context, listen: false);
    String email = _emailController.text;
    String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('$api/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('email', email);
        await prefs.setString('name', jsonResponse['name']);
        await prefs.setString('id', jsonResponse['id']);

        globalState.setEmail(email);
        globalState.setName(jsonResponse['name']);
        globalState.setId(jsonResponse['id']);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login Successful!'),
        ));

        await _checkLocationStatus(); // Check location after login

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid Email or Password'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.reasonPhrase}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isOffline
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No Internet Connection',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _checkNetworkStatus,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purpleAccent,
                      Colors.amber,
                      Colors.blue,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 200,
                      width: 300,
                      child: LottieBuilder.asset("assets/lottie/login2.json"),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 325,
                      height: 470,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            "Welcome",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Please Login to Your Account",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: 260,
                            height: 60,
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                suffix: Icon(FontAwesomeIcons.envelope,
                                    color: Colors.red),
                                labelText: "Email Address",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 260,
                            height: 60,
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                labelText: "Password",
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: login,
                            child: Container(
                              alignment: Alignment.center,
                              width: 250,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF8A2387),
                                    Color(0xFFE94057),
                                    Color(0xFFF27121),
                                  ],
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 17),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
