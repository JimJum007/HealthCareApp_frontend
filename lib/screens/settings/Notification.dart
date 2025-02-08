import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _eventList = [
    {
      'title': 'เรียนวิชา 1',
      'time': '09:00-12:00',
      'date': '19 ธ.ค. 2024',
    },
    {
      'title': 'ประชุมงาน',
      'time': '15:30',
      'date': '19 ธ.ค. 2024',
    },
    {
      'title': 'นัดกินข้าวกับคนพิเศษ',
      'time': '17:00',
      'date': '19 ธ.ค. 2024',
    },
    {
      'title': 'ออกกำลังกาย',
      'time': '18:00',
      'date': '19 ธ.ค. 2024',
    },
  ];

  void _addNotification() {
    // ฟังก์ชันเพิ่ม Notification ใหม่
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController timeController = TextEditingController();
        final TextEditingController dateController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Notification'),
          content: Column(

            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _eventList.add({
                    'title': titleController.text,
                    'time': timeController.text,
                    'date': dateController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editNotification(int index) {
    // ฟังก์ชันแก้ไข Notification
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController =
        TextEditingController(text: _eventList[index]['title']);
        final TextEditingController timeController =
        TextEditingController(text: _eventList[index]['time']);
        final TextEditingController dateController =
        TextEditingController(text: _eventList[index]['date']);

        return AlertDialog(
          title: const Text('Edit Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _eventList[index] = {
                    'title': titleController.text,
                    'time': timeController.text,
                    'date': dateController.text,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _eventList.length,
        itemBuilder: (context, index) {
          final event = _eventList[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${event['date']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${event['time']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _editNotification(index),
                      child: const Text(
                        'edit',
                        style: TextStyle(
                          color: Colors.cyan,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNotification,
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}