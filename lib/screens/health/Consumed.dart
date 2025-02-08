import 'package:flutter/material.dart';
import 'package:healthcare/screens/health/FoodRecordEdit.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:healthcare/screens/health/FoodRecord.dart';
import 'package:intl/intl.dart';

class CaloriesConsumedScreen extends StatefulWidget {
  @override
  _CaloriesConsumedScreenState createState() => _CaloriesConsumedScreenState();
}

class _CaloriesConsumedScreenState extends State<CaloriesConsumedScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  String _errorMessage = '';

  Future<void> fetchFoodRecords(String userId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse('http://192.168.159.215:3000/food-records/data');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _records = data.map((record) => record as Map<String, dynamic>).toList();
        });
      } else {
        setState(() {
          _errorMessage =
          'Failed to fetch records. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching records: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatDateTime(String date, String time) {
    try {
      // รวมวันที่และเวลาเข้าด้วยกันเพื่อแปลงเป็น DateTime
      final dateTime = DateTime.parse('$date $time').toLocal(); // แปลงเป็นเวลาท้องถิ่น
      final formattedDate = DateFormat('d MMMM yyyy', 'th_TH').format(dateTime); // วันที่แบบไทย
      final formattedTime = DateFormat('h:mm a').format(dateTime); // เวลาแบบ AM/PM
      return '$formattedDate, $formattedTime'; // รวมวันที่และเวลา
    } catch (e) {
      return '$date $time'; // กรณีแปลงไม่ได้ ให้คืนค่าเดิม
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId != null) {
      fetchFoodRecords(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Calories Consumed Today',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : _records.isEmpty
          ? const Center(
        child: Text(
          'No food records found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Calories:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_records.fold(0, (sum, item) => sum + (item['calories'] as int))} Cal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final food = _records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    title: Text(
                      food['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      formatDateTime(food['date'], food['time']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '${food['calories']} Cal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodRecordEditScreen(foodRecord: food), // ✅ ส่งข้อมูลไป
                        ),
                      );

                      if (result == true) {
                        final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                        final userId = authProvider.userId;

                        if (userId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refreshing data...')),
                          );
                          await fetchFoodRecords(userId); // โหลดข้อมูลใหม่
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data refreshed.')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodRecordScreen()),
          );

          if (result == true) {
            final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
            final userId = authProvider.userId;

            if (userId != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
              await fetchFoodRecords(userId); // โหลดข้อมูลใหม่
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data refreshed.')),
              );
            }
          }
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
