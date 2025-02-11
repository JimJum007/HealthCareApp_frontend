import 'package:flutter/material.dart';
import 'screens/health/Home.dart'; // Import หน้า Home
import 'screens/auth/LoginPage.dart';
import 'screens/auth/Signup.dart';
import 'screens/health/Summary.dart'; // Import หน้า Summary
import 'screens/settings/Notification.dart'; // Import หน้า Notification
import 'screens/settings/Setting.dart'; // Import หน้า Setting
import 'package:healthcare/providers/auth_provider.dart';
import 'package:healthcare/providers/food_record_provider.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/activity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // สร้าง AuthProvider และโหลด Token ก่อนเริ่มแอป
  final authProvider = AuthProvider();
  await authProvider.loadToken(); // ✅ โหลด Token ที่นี่ก่อนเรียก runApp()

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => FoodRecordProvider()), // เพิ่ม Provider
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.grey,
        ),
      ),
      initialRoute: authProvider.isAuthenticated ? '/' : '/login', // ✅ ตรวจสอบสถานะล็อกอิน
      routes: {
        '/': (context) => const MainScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Home(),
    SummaryGraphScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.token == null) {
      return const Center(child: CircularProgressIndicator()); // ✅ แสดง Loading จนกว่าจะโหลดเสร็จ
    }

    // หากยังไม่ได้ล็อกอิน ให้เปลี่ยนไปหน้า Login
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
