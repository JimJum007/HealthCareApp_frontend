import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/activity_provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:healthcare/screens/health/Activity.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    Future.delayed(Duration.zero, () {
      Provider.of<ActivityProvider>(context, listen: false).fetchActivities(context, today);
    });
  }

  Future<void> _editNotification(BuildContext context, Map<String, dynamic> activity) async {
    final TextEditingController titleController = TextEditingController(text: activity['name']);
    final TextEditingController startTimeController = TextEditingController(text: activity['startTime']);
    final TextEditingController endTimeController = TextEditingController(text: activity['endTime']);
    final TextEditingController dateController = TextEditingController(text: activity['date']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: startTimeController,
                decoration: const InputDecoration(labelText: 'Start Time'),
              ),
              TextField(
                controller: endTimeController,
                decoration: const InputDecoration(labelText: 'End Time'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateActivity(
                  activity['id'],
                  titleController.text,
                  startTimeController.text,
                  endTimeController.text,
                  dateController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateActivity(int id, String name, String startTime, String endTime, String date) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    final url = Uri.parse('http://192.168.159.215:3000/activity/update/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'startTime': startTime,
          'endTime': endTime,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        _fetchActivities();
      } else {
        print('Failed to update activity: ${response.body}');
      }
    } catch (e) {
      print('Error updating activity: $e');
    }
  }

  Future<void> _deleteActivity(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    final url = Uri.parse('http://192.168.159.215:3000/activity/delete/$id');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _fetchActivities();
      } else {
        print('Failed to delete activity: ${response.body}');
      }
    } catch (e) {
      print('Error deleting activity: $e');
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('hh:mm a').format(dateTime); // แปลงเป็น 12-hour format
    } catch (e) {
      return dateTimeString; // กรณีผิดพลาดให้คืนค่าเดิม
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('EEEE, d MMM yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString; // คืนค่าเดิมในกรณีผิดพลาด
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.cyan, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
          if (activityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (activityProvider.activities.isEmpty) {
            return const Center(child: Text("No activities found.", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: activityProvider.activities.length,
            itemBuilder: (context, index) {
              final event = activityProvider.activities[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.cyan, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                _formatDateTime(event['date']),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.orange, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatTime(event['startTime'])} - ${_formatTime(event['endTime'])}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _editNotification(context, event),
                            icon: const Icon(Icons.edit, color: Colors.cyan),
                            tooltip: 'Edit Activity',
                          ),
                          IconButton(
                            onPressed: () => _deleteActivity(event['id']),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Activity',
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              );
            },
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActivityScreen()),
          ).then((_) {
            _fetchActivities(); // โหลดข้อมูลใหม่เมื่อกลับมาหน้าเดิม
          });
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
