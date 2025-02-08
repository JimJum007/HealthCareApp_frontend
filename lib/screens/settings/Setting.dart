import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/screens/settings/Account.dart';
import 'package:healthcare/screens/settings/Notification.dart';
import 'package:healthcare/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> settingsOptions = [
    {
      'icon': Icons.person,
      'title': 'Account',
      'route': '/account',
    },
    {
      'icon': Icons.notifications,
      'title': 'Notification',
      'route': '/notification',
    },
    {
      'icon': Icons.logout,
      'title': 'Logout',
      'route': '/logout',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: settingsOptions.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final option = settingsOptions[index];
          final isLogout = option['title'] == 'Logout';

          return ListTile(
            leading: Icon(
              option['icon'],
              color: isLogout ? Colors.red : Colors.grey,
            ),
            title: Text(
              option['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: isLogout ? Colors.red : Colors.grey,
            ),
            onTap: () {
              if (option['route'] == '/account') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              } else if (option['route'] == '/notification') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              } else if (option['route'] == '/logout') {
                _showLogoutDialog(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Route not implemented for ${option['title']}'),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider =
                Provider.of<AuthProvider>(context, listen: false);

                await authProvider.logout(context);
                // ใช้ฟังก์ชัน logout ใน AuthProvider
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
