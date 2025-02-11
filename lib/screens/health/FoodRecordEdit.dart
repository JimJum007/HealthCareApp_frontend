import 'package:flutter/material.dart';
import 'package:healthcare/providers/food_record_provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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

  String _convertTo24HourFormat(String hour, String minute, String amPm) {
    int hour24 = int.parse(hour);
    if (amPm == 'PM' && hour24 != 12) {
      hour24 += 12;
    } else if (amPm == 'AM' && hour24 == 12) {
      hour24 = 0;
    }
    return '${hour24.toString().padLeft(2, '0')}:$minute:00';
  }


  @override
  void initState() {
    super.initState();

    menuNameController = TextEditingController();
    caloriesController = TextEditingController();

    if (widget.foodRecord != null) {
      menuName = widget.foodRecord!['name'] ?? '';
      calories = widget.foodRecord!['calories']?.toString() ?? '0';
      menuNameController.text = menuName;
      caloriesController.text = calories;

      if (widget.foodRecord!['time'] != null) {
        final timeParts = widget.foodRecord!['time'].split(' ');
        if (timeParts.length == 2) {
          amPm = timeParts[1];
          final timeNumbers = timeParts[0].split(':');
          if (timeNumbers.length == 2) {
            selectedHour = timeNumbers[0].padLeft(2, '0');
            selectedMinute = timeNumbers[1].padLeft(2, '0');
          }
        }
      }

      final rawDate = widget.foodRecord!['date'];
      try {
        if (rawDate is String) {
          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate)) {
            _selectedDay = DateTime.parse(rawDate);
          } else if (RegExp(r'^[A-Za-z]+ \d{1,2}, \d{4}$').hasMatch(rawDate)) {
            _selectedDay = DateFormat("MMMM d, yyyy").parse(rawDate);
          }
          _focusedDay = _selectedDay!;
        }
      } catch (e) {
        print('❌ Error parsing date: $e');
      }
    }
  }

  void _saveData(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;
    final token = authProvider.token;

    if (userId == null || token == null) {
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

    final time = _convertTo24HourFormat(selectedHour, selectedMinute, amPm);
    final date = _selectedDay?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0];

    try {
      final bool isEditing = widget.foodRecord != null;
      final String url = isEditing
          ? 'http://192.168.159.215:3000/food-records/update/${widget.foodRecord!['id']}'
          : 'http://192.168.159.215:3000/food-records/add_food';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'name': menuName,
          'time': time,
          'date': date,
          'calories': int.tryParse(calories) ?? 0,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food record updated successfully.')),
        );
        Navigator.pop(context, true);
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update food record: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update food record: $e')),
      );
    }
  }

  void _deleteData(BuildContext context) async {
    if (widget.foodRecord == null) return;

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token; // ✅ ดึง Token มาใช้

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please log in first.')),
      );
      return;
    }

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete")),
        ],
      ),
    );

    if (!confirmDelete) return;

    final String deleteUrl = 'http://192.168.159.215:3000/food-records/${widget.foodRecord!['id']}';

    try {
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Authorization': 'Bearer $token', // ✅ เพิ่ม Header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food record deleted successfully.')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete food record.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting food record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Food Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Input Menu Name
            Text("Menu Name"),
            TextField(
              controller: menuNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter menu name",
              ),
              onChanged: (value) => menuName = value,
            ),
            SizedBox(height: 16),

            // 🔹 Input Calories
            Text("Calories"),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter calories",
              ),
              onChanged: (value) => calories = value,
            ),
            SizedBox(height: 16),

            // 🔹 Select Date
            Text("Select Date"),
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDay ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDay = pickedDate;
                  });
                }
              },
              child: Text(
                _selectedDay != null
                    ? DateFormat("yyyy-MM-dd").format(_selectedDay!)
                    : "Pick a date",
              ),
            ),
            SizedBox(height: 16),

            // 🔹 Select Time
            Text("Select Time"),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedHour,
                  items: List.generate(12, (index) {
                    final hour = (index + 1).toString().padLeft(2, '0');
                    return DropdownMenuItem(value: hour, child: Text(hour));
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedHour = value!;
                    });
                  },
                ),
                Text(":"),
                DropdownButton<String>(
                  value: selectedMinute,
                  items: List.generate(60, (index) {
                    final minute = index.toString().padLeft(2, '0');
                    return DropdownMenuItem(value: minute, child: Text(minute));
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedMinute = value!;
                    });
                  },
                ),
                SizedBox(width: 20),
                ToggleButtons(
                  isSelected: [amPm == 'AM', amPm == 'PM'],
                  onPressed: (index) {
                    setState(() {
                      amPm = index == 0 ? 'AM' : 'PM';
                    });
                  },
                  children: [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("AM")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("PM")),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // 🔹 Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _saveData(context),
                  child: Text("Save"),
                ),
                if (widget.foodRecord != null)
                  ElevatedButton(
                    onPressed: () => _deleteData(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
