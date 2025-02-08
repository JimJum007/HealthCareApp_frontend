import 'package:flutter/material.dart';
import 'package:healthcare/providers/food_record_provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodRecordEditScreen extends StatefulWidget {
  final Map<String, dynamic>? foodRecord;

  FoodRecordEditScreen({this.foodRecord});

  @override
  _FoodRecordEditScreenState createState() => _FoodRecordEditScreenState();
}

class _FoodRecordEditScreenState extends State<FoodRecordEditScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String amPm = 'AM';
  String selectedHour = '00';
  String selectedMinute = '00';
  String menuName = '';
  String calories = '';
  late TextEditingController menuNameController;
  late TextEditingController caloriesController;

  @override
  void initState() {
    super.initState();

    // ตั้งค่าเริ่มต้นสำหรับ TextField controllers
    menuNameController = TextEditingController();
    caloriesController = TextEditingController();

    if (widget.foodRecord != null) {
      menuName = widget.foodRecord!['name'];
      calories = widget.foodRecord!['calories'].toString();
      menuNameController.text = menuName;
      caloriesController.text = calories;

      // ดึงค่าเวลา
      final timeParts = widget.foodRecord!['time'].split(' ');
      if (timeParts.length == 2) {
        amPm = timeParts[1];
        final timeNumbers = timeParts[0].split(':');
        if (timeNumbers.length == 2) {
          selectedHour = timeNumbers[0].padLeft(2, '0');
          selectedMinute = timeNumbers[1].padLeft(2, '0');
        }
      }

      // ตรวจสอบและแปลงวันที่
      try {
        _selectedDay = DateTime.parse(widget.foodRecord!['date']);
        _focusedDay = _selectedDay!;
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid date format: ${widget.foodRecord!['date']}')),
          );
        });
      }
    }
  }

  void _saveData(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;

    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in first.')),
        );
      });
      return;
    }

    if (menuName.isEmpty || calories.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')),
        );
      });
      return;
    }

    final time = '$selectedHour:$selectedMinute $amPm';
    final date = _selectedDay?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0];

    try {
      final bool isEditing = widget.foodRecord != null;
      final String url = isEditing
          ? 'http://192.168.1.17:3000/food-records/update/${widget.foodRecord!['id']}'
          : 'http://192.168.1.17:3000/food-records/add_food';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'name': menuName,
          'time': time,
          'date': date,
          'calories': int.tryParse(calories) ?? 0,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food record saved successfully.')),
          );
        });
        Navigator.pop(context, true);
      } else {
        final error = json.decode(response.body)['error'];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save food record: $error')),
          );
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save food record: $e')),
        );
      });
    }
  }

  @override
  void dispose() {
    menuNameController.dispose();
    caloriesController.dispose();
    super.dispose();
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
          'Food Record Edit',
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
                controller: menuNameController,
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
                controller: caloriesController,
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
              // Dropdowns and Calendar widgets go here
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
