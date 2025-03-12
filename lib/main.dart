import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Notification.dart';
import 'feed&post/create_post.dart';
import 'feed&post/feed.dart';
import 'home.dart';
import 'onboarding_screen/onboarding1.dart';
import 'profile/pofile.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting("th_TH", null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SplashScreen(), // เพิ่ม SplashScreen
      routes: {
        '/home': (context) => HomeScreen(),
        '/feed': (context) => FeedPage(),
        '/notification': (context) => NotificationPage(),
        '/profile': (context) => ProfilePage(),
        '/create_post': (context) => CreatePost()
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<Widget> _checkLoginStatus() async {
  final token = await storage.read(key: 'userToken');
  print('Token: $token'); // ตรวจสอบค่าที่อ่านได้
  if (token != null) {
    return HomeScreen();
  } else {
    return OnboardingPage();
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Handle กรณีเกิด error
          return Scaffold(
            body: Center(
              child: Text(
                'Something went wrong!',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          // ใช้ `snapshot.data` โดยไม่ต้องใส่ `!`
          return snapshot.data!;
        } else {
          // Handle กรณีไม่มีข้อมูล
          return Scaffold(
            body: Center(
              child: Text(
                'Unexpected error occurred!',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}

