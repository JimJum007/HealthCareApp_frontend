import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/auth_provider.dart';
import 'package:healthcare/services/api_service.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String startHour = '00';
  String startMinute = '00';
  String amPmStart = 'AM';
  String endHour = '00';
  String endMinute = '00';
  String amPmEnd = 'AM';
  TextEditingController _activityNameController = TextEditingController();
  bool _isSaving = false;
  String date = ''; // ประกาศตัวแปร date แต่ยังไม่กำหนดค่า

  @override
  void initState() {
    super.initState();
    date = DateTime.now().toIso8601String().split('T')[0]; // กำหนดค่าใน initState
  }

  Future<void> _saveActivity() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนบันทึกกิจกรรม')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // ✅ แปลงเวลา 12 ชั่วโมงเป็น 24 ชั่วโมง
    int startHour24 = int.parse(startHour);
    int endHour24 = int.parse(endHour);

    if (amPmStart == "PM" && startHour24 != 12) startHour24 += 12;
    if (amPmStart == "AM" && startHour24 == 12) startHour24 = 0;
    if (amPmEnd == "PM" && endHour24 != 12) endHour24 += 12;
    if (amPmEnd == "AM" && endHour24 == 12) endHour24 = 0;

    // ✅ กำหนดค่าของวันที่ให้อยู่ในรูปแบบ `YYYY-MM-DD`
    String selectedDate = _selectedDay != null
        ? _selectedDay!.toLocal().toIso8601String().split('T')[0]
        : DateTime.now().toLocal().toIso8601String().split('T')[0];

    // ✅ ใช้ `selectedDate` แทน `selectedDateT`
    DateTime startDateTime = DateTime.parse("$selectedDate ${startHour24.toString().padLeft(2, '0')}:${startMinute.padLeft(2, '0')}:00Z");
    DateTime endDateTime = DateTime.parse("$selectedDate ${endHour24.toString().padLeft(2, '0')}:${endMinute.padLeft(2, '0')}:00Z");

    print("🔹 Data being sent: ${{
      'name': _activityNameController.text.trim(),
      'startTime': startDateTime.toIso8601String(),
      'endTime': endDateTime.toIso8601String(),
      'date': selectedDate, // ✅ ใช้ YYYY-MM-DD
    }}");

    try {
      final response = await ApiService.addActivity(token, {
        'name': _activityNameController.text.trim(),
        'startTime': startDateTime.toIso8601String(),
        'endTime': endDateTime.toIso8601String(),
        'date': selectedDate, // ✅ ใช้ YYYY-MM-DD
      });

      print("🔹 Server response: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกกิจกรรมสำเร็จ!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _activityNameController,
                decoration: InputDecoration(
                  labelText: 'Activity Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Time to Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildTimePicker('From', startHour, startMinute, amPmStart, (hour, minute, amPm) {
                setState(() {
                  startHour = hour;
                  startMinute = minute;
                  amPmStart = amPm;
                });
              }),
              _buildTimePicker('To', endHour, endMinute, amPmEnd, (hour, minute, amPm) {
                setState(() {
                  endHour = hour;
                  endMinute = minute;
                  amPmEnd = amPm;
                });
              }),
              const SizedBox(height: 30),
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
              ElevatedButton(
                onPressed: _isSaving ? null : _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, String hour, String minute, String amPm, Function(String, String, String) onChanged) {
    return Column(
      children: [
        Text(label),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: hour,
              items: List.generate(12, (index) => DropdownMenuItem(
                  value: index.toString().padLeft(2, '0'),
                  child: Text(index.toString().padLeft(2, '0'))
              )),
              onChanged: (value) => onChanged(value!, minute, amPm),
            ),
            const Text(' : '),
            DropdownButton<String>(
              value: minute,
              items: List.generate(60, (index) => DropdownMenuItem(
                  value: index.toString().padLeft(2, '0'),
                  child: Text(index.toString().padLeft(2, '0'))
              )),
              onChanged: (value) => onChanged(hour, value!, amPm),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: amPm,
              items: ['AM', 'PM'].map((ampm) => DropdownMenuItem(
                  value: ampm,
                  child: Text(ampm)
              )).toList(),
              onChanged: (value) => onChanged(hour, minute, value!),
            ),
          ],
        ),
      ],
    );
  }
}
