import 'package:bunjai_app/Donate_thing/Donate_thing3.dart';
import 'package:flutter/material.dart';
import 'package:bunjai_app/bottom_bar.dart';

class DonateThing2 extends StatefulWidget {
  final String whatdonatething;
  final String title;

  const DonateThing2({
    Key? key,
    required this.whatdonatething,
    required this.title,
  }): super(key: key);

  @override
  _DonateThingState createState() => _DonateThingState();
}

class _DonateThingState extends State<DonateThing2> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // เพิ่มการนำทางเมื่อเลือกไอคอนต่าง ๆ ใน BottomBar
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home'); // ไปที่หน้า Home
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/feed'); // ไปที่หน้า Feed
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/notification'); // ไปที่หน้า Notifications
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/profile'); // ไปที่หน้า Profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ส่วนหัว
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'ร่วมบริจาค',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'บริจาคสิ่งของ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // ทำให้ส่วน ScrollView ปรับความสูงตามพื้นที่เหลือ
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'F&Q',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  _buildLocationCard(
                    context,
                    'รับบริจาคอะไรบ้าง?',
                    widget.whatdonatething,
                    Icons.location_on,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DonateThing3(
                          title: widget.title,
                        )),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Text('ถัดไป',style: TextStyle(fontSize: 17,color: Colors.white,fontWeight: FontWeight.bold ),),
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when + button is pressed
        },
        backgroundColor: Colors.green,
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.red),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ครอบข้อความ 'ศูนย์รับบริจาค' ด้วย Container และ BoxDecoration
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green, // สีพื้นหลัง
                        borderRadius: BorderRadius.circular(30), // เพิ่มความมนที่มุม
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white, // สีตัวอักษร
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
