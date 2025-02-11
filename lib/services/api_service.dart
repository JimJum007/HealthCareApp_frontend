import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.159.215:3000';

  /// ดึงข้อมูล Food Records
  static Future<List<Map<String, dynamic>>> fetchFoodRecords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/food-records'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List records = json.decode(response.body);
      return records.map((record) => {
        'name': record['name'] ?? 'Unknown',
        'time': record['time'] ?? 'Unknown',
        'date': record['date'] ?? 'Unknown',
        'calories': record['calories'] ?? 0,
      }).toList();
    } else {
      print('Failed to fetch records: ${response.statusCode}');
      throw Exception('Failed to load food records');
    }
  }

  /// เพิ่มข้อมูล Food Record ใหม่
  static Future<void> addFoodRecord(String token, Map<String, dynamic> record) async {
    final response = await http.post(
      Uri.parse('$baseUrl/food-records'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(record),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Failed to add record: ${response.statusCode}');
      throw Exception('Failed to add food record');
    }
  }

  /// ✅ ดึงกิจกรรมตามวันที่
  static Future<List<Map<String, dynamic>>> fetchActivities(String token, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/activity/by-date/$date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print('❌ Failed to fetch activities: ${response.statusCode}');
      throw Exception('Failed to load activities');
    }
  }

  /// ✅ เพิ่มกิจกรรมใหม่
  static Future<void> addActivity(String token, Map<String, dynamic> activity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/activity/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(activity),
    );

    if (response.statusCode != 201) {
      print('❌ Failed to add activity: ${response.statusCode}');
      throw Exception('Failed to add activity');
    }
  }

  /// ✅ อัปเดตกิจกรรม
  static Future<void> updateActivity(String token, int id, Map<String, dynamic> activity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/activity/update/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(activity),
    );

    if (response.statusCode != 200) {
      print('❌ Failed to update activity: ${response.statusCode}');
      throw Exception('Failed to update activity');
    }
  }

  /// ✅ ลบกิจกรรม
  static Future<void> deleteActivity(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/activity/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print('❌ Failed to delete activity: ${response.statusCode}');
      throw Exception('Failed to delete activity');
    }
  }
}
