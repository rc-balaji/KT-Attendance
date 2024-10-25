import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'global/global_state.dart'; // Import the GlobalState provider
import 'pages/Login/login_app.dart';
import 'pages/home_page.dart'; // Import your HomePage here

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = LoginApp(); // Set default to LoginApp
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus(); // Check network first
  }

  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    print(connectivityResult);
    if (connectivityResult[0] == ConnectivityResult.none) {
      // No internet connection
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
    } else {
      // Internet is available
      setState(() {
        _isOffline = false;
      });
      _checkLoginStatus(); // Check login status once network is confirmed
    }
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('loggedIn');

    setState(() {
      _isLoading = true;
    });

    if (loggedIn == true) {
      String? name = prefs.getString('name');
      String? email = prefs.getString('email');
      String? id = prefs.getString('id');

      // Update the global state with the retrieved user info
      if (name != null && email != null && id != null) {
        Provider.of<GlobalState>(context, listen: false)
            .updateUser(id, name, email);
      }

      setState(() {
        _isLoading = false;
        _defaultHome = HomePage();
      });
    } else {
      setState(() {
        _isLoading = false;
        _defaultHome = LoginApp();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primaryColor: Colors.purple,
      ),
      home: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _isOffline
                ? _buildOfflineScreen() // Show offline screen if no network
                : _defaultHome, // Display login/home based on the status
      ),
    );
  }

  // This widget displays when the device is offline
  Widget _buildOfflineScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 100, color: Colors.red),
          SizedBox(height: 20),
          Text(
            "No Internet Connection",
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _checkNetworkStatus(); // Retry checking the network status
            },
            icon: Icon(Icons.refresh),
            label: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
            ),
          ),
        ],
      ),
    );
  }
}
