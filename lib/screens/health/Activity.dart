import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  @override
  Widget build(BuildContext context) {
    // ขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: SingleChildScrollView( // ทำให้เลื่อนหน้าจอได้ถ้าความสูงไม่พอ
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Activity Name Section
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Activity name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.8, // กำหนดความกว้างเป็น 80% ของหน้าจอ
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your Menu',
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

              // Time to Activity Section
              const Center(
                child: Text(
                  'Time to Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('From  '),
                  DropdownButton<String>(
                    value: startHour,
                    items: List.generate(12, (index) {
                      final hour = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: hour,
                        child: Text(hour),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        startHour = value!;
                      });
                    },
                  ),
                  const Text(' : '),
                  DropdownButton<String>(
                    value: startMinute,
                    items: List.generate(60, (index) {
                      final minute = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: minute,
                        child: Text(minute),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        startMinute = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ToggleButtons(
                    isSelected: [amPmStart == 'AM', amPmStart == 'PM'],
                    onPressed: (index) {
                      setState(() {
                        amPmStart = index == 0 ? 'AM' : 'PM';
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text('AM'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text('PM'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('  to     '),
                  DropdownButton<String>(
                    value: endHour,
                    items: List.generate(12, (index) {
                      final hour = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: hour,
                        child: Text(hour),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        endHour = value!;
                      });
                    },
                  ),
                  const Text(' : '),
                  DropdownButton<String>(
                    value: endMinute,
                    items: List.generate(60, (index) {
                      final minute = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: minute,
                        child: Text(minute),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        endMinute = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ToggleButtons(
                    isSelected: [amPmEnd == 'AM', amPmEnd == 'PM'],
                    onPressed: (index) {
                      setState(() {
                        amPmEnd = index == 0 ? 'AM' : 'PM';
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text('AM'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text('PM'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Date Section
              const Center(
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 3),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100,
                ),
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.9, // 90% ของหน้าจอ
                ),
                child: TableCalendar(
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
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
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
                ),
              ),

              const SizedBox(height: 15),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // ฟังก์ชันบันทึก
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02, // ใช้ 2% ของความสูงหน้าจอ
                    ),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}