import 'package:flutter/material.dart';
import 'package:healthcare/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/auth_provider.dart';

class ActivityProvider with ChangeNotifier {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<Map<String, dynamic>> get activities => _activities;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  /// ✅ ดึงกิจกรรมตามวันที่
  Future<void> fetchActivities(BuildContext context, String date) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      print('❌ No token found.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _activities = await ApiService.fetchActivities(token, date);
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ เพิ่มกิจกรรมใหม่
  Future<void> addActivity(BuildContext context, Map<String, dynamic> activity) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      await ApiService.addActivity(token, activity);
      _activities.add(activity);
      notifyListeners();
    } catch (e) {
      print('❌ Error adding activity: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// ✅ อัปเดตกิจกรรม
  Future<void> updateActivity(BuildContext context, int id, Map<String, dynamic> activity) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    try {
      await ApiService.updateActivity(token, id, activity);
      final index = _activities.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _activities[index] = activity;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error updating activity: $e');
    }
  }

  /// ✅ ลบกิจกรรม
  Future<void> deleteActivity(BuildContext context, int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    try {
      await ApiService.deleteActivity(token, id);
      _activities.removeWhere((a) => a['id'] == id);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting activity: $e');
    }
  }
}
