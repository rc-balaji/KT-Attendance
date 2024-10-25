import 'package:flutter/material.dart';

class GlobalState with ChangeNotifier {
  String? _id;
  String? _name;
  String? _email;

  // Getters
  String? get id => _id;
  String? get name => _name;
  String? get email => _email;

  // Method to update the values and notify listeners
  void updateUser(String id, String name, String email) {
    _id = id;
    _name = name;
    _email = email;
    notifyListeners(); // Notify listeners when changes occur
  }

  // Setters
  void setId(String id) {
    _id = id;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  // Method to clear user data (for logout)
  void clearUser() {
    _id = null;
    _name = null;
    _email = null;
    notifyListeners();
  }
}
