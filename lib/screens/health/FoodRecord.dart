import 'package:flutter/material.dart';
import 'package:healthcare/providers/food_record_provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodRecordScreen extends StatefulWidget {
  @override
  _FoodRecordScreenState createState() => _FoodRecordScreenState();
}

class _FoodRecordScreenState extends State<FoodRecordScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String amPm = 'AM';
  String selectedHour = '00';
  String selectedMinute = '00';
  String menuName = '';
  String calories = ''; // เพิ่มตัวแปรสำหรับเก็บแคลอรี

  void _saveData(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId; // ดึง userId จาก AuthProvider

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please log in first.')),
      );
      return;
    }

    if (menuName.isEmpty || calories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    // สร้างเวลาและวันที่ในรูปแบบที่เหมาะสม
    final time = '$selectedHour:$selectedMinute $amPm';
    final date = _selectedDay?.toIso8601String().split('T')[0] ??
        DateTime.now().toIso8601String().split('T')[0];

    try {
      final url = Uri.parse('http://192.168.159.215:3000/food-records/add_food');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId, // ส่ง userId
          'name': menuName,
          'time': time,
          'date': date,
          'calories': int.tryParse(calories) ?? 0, // แปลง calories เป็น int
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food record saved successfully.')),
        );
        Navigator.pop(context,true);
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save food record: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save food record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<FoodRecordProvider>().isSaving;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Food Record',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    menuName = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter your menu name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Calories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    calories = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter calories',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Time to Eat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedHour,
                    items: List.generate(12, (index) {
                      final hour = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: hour,
                        child: Text(hour),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedHour = value!;
                      });
                    },
                  ),
                  const Text(' : '),
                  DropdownButton<String>(
                    value: selectedMinute,
                    items: List.generate(60, (index) {
                      final minute = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: minute,
                        child: Text(minute),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMinute = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  ToggleButtons(
                    isSelected: [amPm == 'AM', amPm == 'PM'],
                    onPressed: (index) {
                      setState(() {
                        amPm = index == 0 ? 'AM' : 'PM';
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('AM'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('PM'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.cyan,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving ? null : () => _saveData(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

