import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bottom_bar.dart'; // นำเข้า BottomBar ที่คุณสร้างไว้

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 2; // Index เริ่มต้นของ Notification Page

  // ฟังก์ชันสำหรับจัดการการเปลี่ยนหน้า
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // ตัวอย่างการเปลี่ยนหน้า (แก้ไขตามการใช้งานของคุณ)
    if (index == 0) {
      // ไปที่หน้า Home
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      // ไปที่หน้า Feed
      Navigator.pushReplacementNamed(context, '/feed');
    } else if (index == 2) {
      // Notification อยู่หน้าเดิม
    } else if (index == 3) {
      // ไปที่หน้า Profile
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'previously',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // จำนวนการแจ้งเตือน
                itemBuilder: (context, index) {
                  return NotificationTile();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,  // ส่งค่า index ที่ถูกเลือกไปที่ BottomBar
        onItemTapped: _onItemTapped,    // ฟังก์ชันที่เรียกใช้เมื่อมีการกดใน BottomBar
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when + button is pressed
        },
        backgroundColor: Colors.green,
        shape: CircleBorder(), // Set the shape to CircleBorder to make it circular
        child: Icon(Icons.add, size: 28,color: Colors.white,), // ลดขนาดไอคอน
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Centered the FAB
    );
  }
}

class NotificationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuih7dK4A8nj1f1fdwPI8HapaYPhyjzl9zlA&s'), // ตัวอย่างรูปโปรไฟล์
          radius: 20,
        ),
        title: Text('มูลนิธิสากลเพื่อคนพิการ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('มูลนิธิสากลเพื่อคนพิการได้พิสูจน์ให้ทุกท่านเห็นแล้วว่า...'),
            SizedBox(height: 5),
            Text(
              DateFormat('d MMM yyyy').format(DateTime.now()), // แสดงวันที่
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(Icons.circle, color: Colors.blue, size: 10),
      ),
    );
  }
}
