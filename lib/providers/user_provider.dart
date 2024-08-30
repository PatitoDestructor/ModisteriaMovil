// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  Future<void> saveUser(User user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    notifyListeners();
  }
}
