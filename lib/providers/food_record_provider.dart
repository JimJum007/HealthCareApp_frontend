import 'package:flutter/foundation.dart';
import 'package:healthcare/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodRecordProvider with ChangeNotifier {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<Map<String, dynamic>> get records => _records;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  /// ✅ ดึงข้อมูล Food Records (ใช้ API `/food-records/weekly-summary`)
  Future<void> fetchRecords(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      print('⚠ Token expired! Logging out...');
      await authProvider.logout(context);
      return;
    }

    final token = authProvider.token;
    if (token == null) {
      print('No token found.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://192.168.159.215:3000/food-records/weekly-summary'), // ✅ ใช้ API weekly-summary
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        _records = data.entries.map((entry) {
          return {
            'date': entry.key,
            'meals': entry.value['meals'] ?? 0,
            'calories': entry.value['calories']?.toDouble() ?? 0.0,
          };
        }).toList();
        notifyListeners();
      } else {
        print('❌ Failed to fetch records: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ บันทึกข้อมูล Food Record ใหม่
  Future<void> saveFoodRecord({
    required BuildContext context,
    required String name,
    required String time,
    required String date,
    required int calories,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      print('⚠ Token expired! Logging out...');
      await authProvider.logout(context);
      return;
    }

    final token = authProvider.token;
    if (token == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.159.215:3000/food-records'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'time': time,
          'date': date,
          'calories': calories,
        }),
      );

      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        _records.add({
          'name': name,
          'time': time,
          'date': date,
          'calories': calories,
        });
        notifyListeners();
      } else {
        print('❌ Failed to save record: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving food record: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
