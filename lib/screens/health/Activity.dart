import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:healthcare/providers/activity_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ActivityScreen(),
    );
  }
}

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String amPmStart = 'AM';
  String amPmEnd = 'AM';
  String startHour = '00';
  String startMinute = '00';
  String endHour = '00';
  String endMinute = '00';
  TextEditingController _activityNameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveActivity() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save activity.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final String startTime = "$startHour:$startMinute $amPmStart";
    final String endTime = "$endHour:$endMinute $amPmEnd";
    final String date = _selectedDay?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0];

    try {
      await activityProvider.addActivity(context, {
        'name': _activityNameController.text.trim(),
        'startTime': startTime,
        'endTime': endTime,
        'date': date,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Activity name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: TextField(
                        controller: _activityNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter activity name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Time to Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              // Time selection UI remains unchanged
              const SizedBox(height: 15),
              Center(
                child: Text(
                  'Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 3),
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.cyan, shape: BoxShape.circle),
                  outsideDaysVisible: false,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
