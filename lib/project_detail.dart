import 'package:bunjai_app/Donate_money/Donate_money1.dart';
import 'package:bunjai_app/Donate_thing/Donate_thing1.dart';
import 'package:flutter/material.dart';
import 'bottom_bar.dart'; // import BottomBar ที่สร้างไว้

class ProjectDetailPage extends StatefulWidget {
  final List<String> donatetype;
  final String title;
  final String projectownername;
  final String banktype;
  final String banknumber;
  final String qrcodedonate;
  final String donationcenter;
  final String sendparcel;
  final String whatdonatething;

  const ProjectDetailPage({
    Key? key,
    required this.donatetype,
    required this.title,
    required this.projectownername,
    required this.banknumber,
    required this.banktype,
    required this.qrcodedonate,
    required this.donationcenter,
    required this.sendparcel,
    required this.whatdonatething,
  }) : super(key: key);

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ร่วมบริจาคให้กับ',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.title, // ใช้ title ที่ส่งเข้ามา
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'รูปแบบการบริจาค',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // ตรวจสอบ donatetype
            if (widget.donatetype.contains('บริจาคเงิน'))
              DonationOptionCard(
                title: 'บริจาคเงิน',
                imageUrl:
                    'https://www.punboon.org/_next/static/images/qr-170c8fa8d9dd5a7a9a6be9aa1b875e45.jpeg', // รูป e-Donation
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonateMoneyScreen(
                        title: widget.title,
                        projectownername: widget.projectownername,
                        banknumber: widget.banknumber,
                        banktype: widget.banktype,
                        qrcodedonate: widget.qrcodedonate,
                      ),
                    ),
                  );
                },
              ),
            if (widget.donatetype.contains('บริจาคเงิน') &&
                widget.donatetype.contains('บริจาคสิ่งของ'))
              const SizedBox(height: 20), // เว้นระยะห่างระหว่างการ์ด
            if (widget.donatetype.contains('บริจาคสิ่งของ'))
              DonationOptionCard(
                title: 'บริจาคพัสดุ',
                imageUrl:
                    'https://www.mirror.or.th/img/btn_11.png', // รูปรถรับบริจาค
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonateThing(
                        title: widget.title,
                        donationcenter: widget.donationcenter,
                        sendparcel: widget.sendparcel,
                        whatdonatething: widget.whatdonatething,
                      ),
                    ),
                  );
                },
              ),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when + button is pressed
        },
        backgroundColor: Colors.green,
        shape:
            const CircleBorder(), // Set the shape to CircleBorder to make it circular
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

class DonationOptionCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const DonationOptionCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // ปรับความกว้างของการ์ด
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20, // ปรับขนาดตัวอักษร
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Image.network(
              imageUrl,
              height: 120, // ปรับขนาดรูปให้ใหญ่ขึ้น
              width: 270, // ปรับขนาดรูปให้ใหญ่ขึ้น
            ),
          ],
        ),
      ),
    );
  }
}
