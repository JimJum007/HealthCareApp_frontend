import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:healthcare/screens/settings/EditProfile.dart'; // Import EditProfile

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccountScreen(),
    );
  }
}

class AccountScreen extends StatelessWidget {
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
          'Account',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // พื้นหลังสีขาวของ AppBar
        elevation: 0, // ลบเงา AppBar
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Profile Picture Section
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: CachedNetworkImageProvider(
                    'https://i.pinimg.com/236x/84/3e/f3/843ef3edbdd2d4c3339bd82464278666.jpg',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.cyan,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: () {
                        // ฟังก์ชันเปลี่ยนรูปโปรไฟล์
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // User Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Name
                UserInfoRow(label: 'Name', value: 'Dontree Radiant'),

                SizedBox(height: 10),

                // Email
                UserInfoRow(label: 'Email', value: 'DontreeInwza007x@gmail.com'),

                SizedBox(height: 10),

                // Date of Birth
                UserInfoRow(label: 'Date of Birth', value: '09/09/1999'),

                SizedBox(height: 10),

                // Country/Region
                UserInfoRow(label: 'Country/Region', value: 'Thailand'),
              ],
            ),
          ),

          const Spacer(),

          // Floating Action Button
          Padding(
            padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to EditProfileScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  );
                },
                backgroundColor: Colors.cyan,
                child: const Icon(Icons.edit, size: 28, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const UserInfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label : ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
