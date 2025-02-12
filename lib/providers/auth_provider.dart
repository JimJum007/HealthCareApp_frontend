import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? _token;
  String? _userId;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;

  bool isTokenExpired() {
    if (_token == null) return true;
    try {
      final jwt = JWT.decode(_token!);
      final expiryDate = jwt.payload['exp'] as int?;
      if (expiryDate == null) return true;

      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return currentTime >= expiryDate;
    } catch (e) {
      print("Error decoding token: $e");
      return true;
    }
  }

  Future<void> loadToken() async {
    try {
      _token = await secureStorage.read(key: 'token');
      _userId = await secureStorage.read(key: 'userId');

      if (_token != null && _userId != null && !isTokenExpired()) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _token = null;
        _userId = null;
      }

      print('Token Loaded: $_token');
      print('User ID Loaded: $_userId');
      print('IsAuthenticated: $_isAuthenticated');

      notifyListeners();
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  Future<void> login(String token, String userId) async {
    try {
      _token = token;
      _userId = userId;
      _isAuthenticated = !isTokenExpired();

      await secureStorage.write(key: 'token', value: token);
      await secureStorage.write(key: 'userId', value: userId);
      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      _token = null;
      _userId = null;
      _isAuthenticated = false;

      await secureStorage.deleteAll();
      notifyListeners();

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
