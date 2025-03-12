import 'package:bunjai_app/Donate_money/Donate_money3.dart';
import 'package:flutter/material.dart';

import '../bottom_bar.dart';

class DonateMoneyScreen2 extends StatelessWidget {
  final String qrcodedonate;
  final String title;

  const DonateMoneyScreen2({
    Key? key,
    required this.qrcodedonate,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('URL: $qrcodedonate');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'ร่วมบริจาค\n$title',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'สแกนบริจาค',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Image.network(
                  'https://www.punboon.org/_next/static/images/qr-170c8fa8d9dd5a7a9a6be9aa1b875e45.jpeg', // URL ของโลโก้ e-Donation
                  width: 250,
                ),
                SizedBox(height: 10),
                Image.network(
                  qrcodedonate,
                  width: 250,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'ไม่สามารถโหลดรูปภาพได้',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'คำแนะนำการบริจาคเงินผ่าน QR Code ด้วย Mobile Banking',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 10),
                _buildInstructionText('1. เปิดแอปพลิเคชันที่มี QR Code'),
                _buildInstructionText('2. สแกน QR Code ที่ปรากฏในรูปภาพ'),
                _buildInstructionText('3. ระบุจำนวนเงินที่ต้องการบริจาค'),
                _buildInstructionText('4. ยืนยันการทำธุรกรรมการบริจาค'),
                SizedBox(height: 10),
                Text(
                  'โปรดตรวจสอบยอดเงินและข้อมูลโครงการให้ถูกต้องก่อนยืนยัน',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'ระบบจะส่งใบเสร็จรับเงินอิเล็กทรอนิกส์ให้ท่านทางอีเมลที่ลงทะเบียน',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DonateMoney3(
                                title: title,
                              )),
                    );
                  },
                  child: Text(
                    'ถัดไป',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Action when + button is pressed
          },
          backgroundColor: Colors.green,
          shape: CircleBorder(),
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomBar(
            selectedIndex: 0, // เปลี่ยนเป็น index ของหน้านี้ (0 = Home)
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/feed');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/notification');
              } else if (index == 3) {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
          ),
        ));
  }

  Widget _buildInstructionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        textAlign: TextAlign.center,
      ),
    );
  }
}
