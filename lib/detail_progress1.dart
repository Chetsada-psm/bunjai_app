import 'package:flutter/material.dart';

class DetailProgress1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("โปรเจค"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'https://www.donationhub.or.th/image_project_progress/58/8SLnAGR7tI5tYTv0Ov3lfFabb2oOtPjHJDaVjbYP.jpeg', // Replace with your image URL
                width: 500, // Increased width
                height: 300, // Increased height
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'วันที่ 31 มกราคม 2567',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'ขอบคุณทุกคนที่บริจาค',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'ยอดบริจาคทั้งหมดจนถึงวันที่\n30 มกราคม 2567 เป็นจำนวนเงิน\n174,016 บาท',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'รายละเอียด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'ในวันนี้เรารู้สึกเป็นเกียรติอย่างยิ่งที่ได้ร่วมกันเปิดโครงการอันทรงคุณค่านี้ ซึ่งมีวัตถุประสงค์เพื่อช่วยเหลือผู้ด้อยโอกาสที่มีความบกพร่องทางการได้ยิน โดยเราได้มอบเครื่องช่วยฟังชนิดทัดหลังใบหูระบบดิจิตอล จำนวน 21 เครื่อง พร้อมด้วยเครื่องอบไล่ความชื้น ให้แก่ผู้ที่มีความบกพร่องทางการได้ยินโดยไม่คิดมูลค่าใด ๆ เพื่อให้พวกเขามีโอกาสสื่อสารและใช้ชีวิตได้อย่างมีประสิทธิภาพมากยิ่งขึ้น',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'ข้อมูลการรับบริจาคในปีที่ผ่านมา... (เนื้อหาเพิ่มเติม)',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
