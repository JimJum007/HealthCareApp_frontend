import 'package:flutter/material.dart';
import 'package:healthcare/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/auth_provider.dart';

class ActivityProvider with ChangeNotifier {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> fetchActivities(BuildContext context, String date) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _activities = await ApiService.fetchActivities(token, date);
    } catch (e) {
      print('Error fetching activities: $e');
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  /// ✅ **เพิ่มฟังก์ชันเพิ่มกิจกรรม**
  Future<void> addActivity(BuildContext context, Map<String, dynamic> activityData) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      print('ไม่มี Token');
      return;
    }

    try {
      await ApiService.addActivity(token, activityData);
      _activities.add(activityData); // เพิ่มกิจกรรมใหม่ลงใน List
      notifyListeners();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเพิ่มกิจกรรม: $e');
    }
  }
}
