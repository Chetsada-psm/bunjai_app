import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:bunjai_app/bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<File> _selectedImages = [];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  Future<void> _uploadDataToFirebase() async {
  if (_nameController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _selectedImages.isEmpty ||
      _selectedStartDate == null ||
      _selectedEndDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
    return;
  }

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("ไม่พบ User ID");
    }

    String userId = user.uid;

    // 👉 ดึงข้อมูล username จาก Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      throw Exception("ไม่พบข้อมูลผู้ใช้ในฐานข้อมูล");
    }

    String username = userDoc['username'] ?? 'ไม่ทราบชื่อ';
    String firstname = userDoc['firstName'] ?? 'ไม่ทราบชื่อจริง';
    String lastname = userDoc['lastName'] ?? 'ไม่ทราบนามสกิล';

    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      String? imageUrl = await _convertImageToUrl(image);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      } else {
        throw Exception("เกิดข้อผิดพลาดในการอัปโหลดภาพไปยัง Cloudinary");
      }
    }

    String docId = FirebaseFirestore.instance.collection('feed').doc().id;

    await FirebaseFirestore.instance.collection('feed').doc(docId).set({
      'ID': docId,
      'user_id': userId,      // 🆕 เก็บ user_id
      'username': username,   // 🆕 เก็บ username
      'firstName': firstname,
      'lastName' : lastname,
      'ActivityName': _nameController.text,
      'Activitydetail': _descriptionController.text,
      'ActivityStartDate': _selectedStartDate?.toIso8601String(),
      'ActivityEndDate': _selectedEndDate?.toIso8601String(),
      'image': imageUrls,
      'created_at': FieldValue.serverTimestamp(), // 🆕 Timestamp อัตโนมัติ
      'likes': 0,
      'comments': [],
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')));
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'สร้างกิจกรรม',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'เขียนกิจกรรม',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('ชื่อกิจกรรม', _nameController),
              SizedBox(height: 10),
              _buildTextField('รายละเอียดกิจกรรม', _descriptionController,
                  maxLines: 5),
              SizedBox(height: 20),
              Text(
                'รูปภาพกิจกรรม',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 20,
              ),
              _buildImageUploader(),
              SizedBox(height: 20),
              _buildDatePickerField('วันเริ่มกิจกรรม', isStartDate: true),
              SizedBox(height: 20),
              _buildDatePickerField('วันสิ้นสุดกิจกรรม', isStartDate: false),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _uploadDataToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('เสร็จสิ้น',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          BottomBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }

  Future<String?> _convertImageToUrl(File imageFile) async {
    final String cloudName = 'dea5tmnil';
    final String uploadPreset = 'ข้อมูลโครงการ';
    final Uri apiUrl =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    _showUploadingAnimation();

    try {
      final request = http.MultipartRequest('POST', apiUrl)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      Navigator.of(context).pop(); // ✅ ปิด Loading Animation

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return data['secure_url'] as String?;
      } else {
        print("Upload Error: ${response.statusCode} - $responseData");
        return null;
      }
    } catch (e) {
      Navigator.of(context).pop();
      print("Error uploading image: $e");
      return null;
    }
  }

  void _showUploadingAnimation() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: Lottie.asset('assets/images/Animation1.json')));
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: labelText),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String labelText, {required bool isStartDate}) {
    DateTime? selectedDate =
        isStartDate ? _selectedStartDate : _selectedEndDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: selectedDate == null
                ? 'เลือกวันที่'
                : DateFormat('dd/MM/yyyy').format(selectedDate),
          ),
          onTap: () => _pickDate(context, isStartDate),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Widget _buildImageUploader() {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _selectedImages.map((image) {
            return GestureDetector(
              onTap: () => _showFullImage(image),
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
        if (_selectedImages.length < 1) // Adjust the limit as needed
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (_selectedImages.length < 5) {
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
}
