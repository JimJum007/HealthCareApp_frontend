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
}
