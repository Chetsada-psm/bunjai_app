import 'package:flutter/material.dart';

class bottombar extends StatefulWidget {
  @override
  _BottombarState createState() => _BottombarState();
}

class _BottombarState extends State<bottombar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // เปลี่ยนหน้าเมื่อเลือก Bottom Navigation
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/feed');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/notification');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Current selected page: $_selectedIndex'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when + button is pressed
        },
        backgroundColor: Colors.green,
        shape: const CircleBorder(), // ทำให้ปุ่มเป็นวงกลม
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // ให้ปุ่มอยู่ตรงกลาง
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(), // เพิ่ม notch ให้ปุ่มลอยได้
      notchMargin: 6.0, // กำหนดระยะห่างของ notch
      elevation: 4,
      child: Container(
        height: 60.0, // ความสูงของ BottomBar
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomBarItem(Icons.home, 0, "Home"),
            _buildBottomBarItem(Icons.language, 1, "Feed"),
            SizedBox(width: 48), // ช่องว่างตรงกลางให้ FloatingActionButton
            _buildBottomBarItem(Icons.notifications, 2, "Notifications"),
            _buildBottomBarItem(Icons.person, 3, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, int index, String label) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0, // จัดตำแหน่งให้ icon ขยับขึ้น
            child: IconButton(
              icon: Icon(
                icon,
                color: isSelected ? Colors.green : Colors.grey,
                size: 30,
              ),
              onPressed: () => onItemTapped(index),
              padding: EdgeInsets.zero,
            ),
          ),
          Positioned(
            bottom: 0, // จัดตำแหน่งให้ text อยู่ชิดล่าง
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
