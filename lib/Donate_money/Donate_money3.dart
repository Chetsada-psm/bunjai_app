import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reorderables/reorderables.dart';

class DonateMoney3 extends StatefulWidget {
  final String title;

  const DonateMoney3({Key? key, required this.title}) : super(key: key);

  @override
  _DonateMoney3State createState() => _DonateMoney3State();
}

class _DonateMoney3State extends State<DonateMoney3> {
  final TextEditingController _amountController = TextEditingController();
  List<File> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'กรอกรายละเอียดการชำระเงิน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildAmountField('จำนวนเงินที่บริจาค'),
              SizedBox(height: 20),
              _buildImageUploader(),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    'เสร็จสิ้น',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'ร่วมบริจาค',
            style: TextStyle(
                color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            widget.title,
            style: TextStyle(
                color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Amount Field
  Widget _buildAmountField(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // Image Uploader
  Widget _buildImageUploader() {
    return Column(
      children: [
        ReorderableWrap(
          spacing: 10,
          runSpacing: 10,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex--; // Adjust newIndex if oldIndex is less than newIndex
              }
              final File movedImage = _selectedImages.removeAt(oldIndex);
              _selectedImages.insert(newIndex, movedImage);
            });
          },
          children: _selectedImages.map((image) {
            return GestureDetector(
              key: ValueKey(image),
              onTap: () {
                _showFullImage(
                    image); // ใช้ฟังก์ชันแสดงภาพขนาดเต็มที่เราต้องการ
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.remove(image);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        if (_selectedImages.length < 1)
          DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(12),
            padding: EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: Container(
                height: 100,
                width: 100,
                color: Colors.grey[200],
                child: IconButton(
                  icon: Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Pick Image
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (_selectedImages.length < 1) {
          _selectedImages.add(File(pickedFile.path));
        }
      });
    }
  }

  void _showFullImage(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black,
            child: Image.file(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDonation() async {
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null ||
        double.parse(_amountController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกจำนวนเงินที่ถูกต้อง')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเพิ่มรูปภาพ')),
      );
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนบริจาค')),
        );
        return;
      }

      String userId = currentUser.uid;

      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      var userData = userSnapshot.data() ?? {};
      String username = userData['username'] ?? 'ไม่ทราบชื่อ';
      String firstname = userData['firstName'] ?? '';
      String lastname = userData['lastName'] ?? '';

      // ✅ อัปโหลดรูปภาพแรกแล้วได้ URL
      String imageUrl = await _convertImageToUrl(_selectedImages.first);
      double amount = double.parse(_amountController.text);

      // ✅ บันทึกข้อมูลการบริจาคลง Firestore
      await FirebaseFirestore.instance.collection('เก็บข้อมูลdonate').add({
        'amount': amount,
        'date': DateTime.now().toString(),
        'image': imageUrl,
        'title': widget.title,
        'userId': userId,
        'username': username,
        'firstName': firstname,
        'lastName': lastname,
      });

      // ✅ อัปเดต raisedAmount และ donated ใน "cardของbanner"
      await _updateCardBanner(amount);
      // ✅ อัปเดต donationhistory ของผู้ใช้
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'donationhistory':
            FieldValue.increment(amount.toInt()), // แปลงเป็นจำนวนเต็มก่อนบันทึก
      });

      // 🎉 แสดง Animation สำเร็จ
      _showSuccessAnimation(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

// ฟังก์ชันอัปเดตข้อมูลใน "cardของbanner"
  Future<void> _updateCardBanner(double amount) async {
    try {
      var bannerQuery = await FirebaseFirestore.instance
          .collection('cardของbanner')
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (bannerQuery.docs.isNotEmpty) {
        var bannerDoc = bannerQuery.docs.first;
        var bannerRef = bannerDoc.reference;
        var bannerData = bannerDoc.data();

        int currentRaisedAmount = (bannerData['raisedAmount'] ?? 0).toInt();
        int currentDonated = (bannerData['donated'] ?? 0).toInt();

        await bannerRef.update({
          'raisedAmount':
              (currentRaisedAmount + amount).toInt(), // 🔹 แปลงเป็นจำนวนเต็ม
          'donated': currentDonated + 1,
        });
      } else {
        print('ไม่พบเอกสารที่ตรงกับ title: ${widget.title}');
      }
    } catch (e) {
      print('Error updating cardของbanner: $e');
    }
  }

  Future<String> _convertImageToUrl(File imageFile) async {
    final String cloudName = 'dea5tmnil'; // Cloud Name ของคุณ
    final String uploadPreset = 'ข้อมูลdonate'; // Upload Preset ที่สร้างไว้
    final Uri apiUrl =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      // แสดง Animation1 ตอนเริ่มอัปโหลด
      _showUploadingAnimation(context);

      final bytes = await imageFile.readAsBytes();

      final request = http.MultipartRequest('POST', apiUrl)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: imageFile.path.split('/').last));

      final response = await request.send();

      Navigator.of(context).pop(); // ปิด Animation1 เมื่ออัปโหลดเสร็จ

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['secure_url']; // คืนค่า URL ของรูปภาพ
      } else {
        final errorResponse = await response.stream.bytesToString();
        throw Exception(
            'Upload Error: ${response.statusCode} - $errorResponse');
      }
    } catch (e) {
      Navigator.of(context).pop(); // ปิด Animation1 กรณีเกิดข้อผิดพลาด
      throw Exception('ไม่สามารถอัปโหลดรูปภาพได้: $e');
    }
  }

  // Show Success Dialog
  void _showUploadingAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset('assets/images/Animation1.json'),
        );
      },
    );
  }

// ฟังก์ชันสำหรับแสดง Animation2
  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
            'assets/images/Animation2.json',
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                Navigator.of(context).pop(); // ปิด Animation2
                Navigator.of(context)
                    .popUntil((route) => route.isFirst); // กลับไปยังหน้าแรก
              });
            },
          ),
        );
      },
    );
  }
}
