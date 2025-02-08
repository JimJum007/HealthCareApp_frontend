import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healthcare/providers/auth_provider.dart';

class AuthService {
  final String baseUrl = 'http://192.168.159.215:3000/auth';

  Future<String?> login(BuildContext context, String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] == null || data['user'] == null || data['user']['id'] == null) {
          return 'Invalid server response.';
        }

        final token = data['token'];
        final userId = data['user']['id'].toString();

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(token, userId); // ✅ ใช้ `authProvider.login()`

        return null; // Login สำเร็จ
      } else {
        return jsonDecode(response.body)['message'] ?? 'Login failed.';
      }
    } catch (e) {
      return 'Failed to connect to the server. Please check your internet connection.';
    }
  }

  Future<String?> signUp(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return null; // Sign Up สำเร็จ
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Sign up failed.';
        return message;
      }
    } catch (e) {
      print('Sign Up Error: $e');
      return 'Failed to connect to the server. Please try again.';
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout(context); // ✅ ใช้ `authProvider.logout()`
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
