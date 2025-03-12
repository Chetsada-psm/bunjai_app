import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DonateThing3 extends StatefulWidget {
  final String title;

  const DonateThing3({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _DonateThing3State createState() => _DonateThing3State();
}

class _DonateThing3State extends State<DonateThing3> {
  List<Widget> _inputFields = [];
  List<TextEditingController> itemControllers = []; // Controllers for items
  List<TextEditingController> amountControllers = []; // Controllers for amounts
  DateTime? _selectedDate;
  List<File> _selectedImages = [];
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addInputField(); // Add the first input field on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'ร่วมบริจาค',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                  'กรอกจำนวนสิ่งของที่บริจาค',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: _inputFields,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addInputField,
                    icon: Icon(Icons.add),
                    label: Text(
                      'เพิ่มรายการ',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed:
                        _inputFields.length > 1 ? _removeInputField : null,
                    icon: Icon(Icons.remove),
                    label: Text(
                      'ลบรายการ',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDatePickerField('วันที่บริจาค'),
              SizedBox(height: 20),
              _buildTextField('ที่อยู่จัดส่ง', maxLines: 5),
              SizedBox(height: 20),
              Text(
                'รูปยืนยันการบริจาค',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildImageUploader(),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData, // แก้ไขให้เรียกฟังก์ชัน _submitData
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'เสร็จสิ้น',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLottieDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/images/Animation1.json',
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: Lottie.asset(
                            'assets/images/Animation2.json',
                            onLoaded: (composition) {
                              Future.delayed(composition.duration, () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              });
                            },
                          ),
                        );
                      },
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUploader() {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(
            _selectedImages.length,
            (index) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImages[index],
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
                        _selectedImages.removeAt(index);
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
          ),
        ),
        if (_selectedImages.length < 10)
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
        if (_selectedImages.length >= 10)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'ไม่สามารถเพิ่มรูปได้เกิน 10 รูป',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
        if (_selectedImages.length < 10) {
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

  Widget _buildDatePickerField(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: _selectedDate == null
                ? 'เลือกวันที่'
                : DateFormat('dd/MM/yyyy').format(_selectedDate!),
          ),
          onTap: () => _pickDate(context),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildInputField(
      String itemLabel,
      String amountLabel,
      TextEditingController itemController,
      TextEditingController amountController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(itemLabel, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: itemController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'กรอกชื่อสิ่งของที่บริจาค',
          ),
        ),
        SizedBox(height: 10),
        Text(amountLabel, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'กรอกจำนวน',
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _addInputField() {
    final itemController = TextEditingController();
    final amountController = TextEditingController();
    itemControllers.add(itemController);
    amountControllers.add(amountController);

    _inputFields.add(
      _buildInputField(
          'รายการสิ่งของ', 'จำนวน', itemController, amountController),
    );
    setState(() {});
  }

  void _removeInputField() {
    if (_inputFields.length > 1) {
      itemControllers.removeLast();
      amountControllers.removeLast();
      _inputFields.removeLast();
      setState(() {});
    }
  }

  Widget _buildTextField(String labelText, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        TextField(
          maxLines: maxLines,
          controller: _locationController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'กรอกที่อยู่จัดส่ง',
          ),
        ),
      ],
    );
  }

  Future<List<String>> _convertImagesToUrls(List<File> imageFiles) async {
    final String cloudName = 'dea5tmnil'; // Cloud Name ของคุณ
    final String uploadPreset = 'ข้อมูลdonate'; // Upload Preset ที่สร้างไว้
    final Uri apiUrl =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    List<String> imageUrls = [];

    for (File imageFile in imageFiles) {
      try {
        final bytes = await imageFile.readAsBytes();

        final request = http.MultipartRequest('POST', apiUrl)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(http.MultipartFile.fromBytes('file', bytes,
              filename: imageFile.path.split('/').last));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final data = jsonDecode(responseData);
          imageUrls.add(data['secure_url']);
        } else {
          final errorResponse = await response.stream.bytesToString();
          throw Exception(
              'Upload Error: ${response.statusCode} - $errorResponse');
        }
      } catch (e) {
        throw Exception('ไม่สามารถอัปโหลดรูปภาพได้: $e');
      }
    }

    return imageUrls;
  }

  Future<void> _submitData() async {
    if (!mounted) return;

    try {
      // ตรวจสอบข้อมูล
      if (_selectedDate == null ||
          _locationController.text.isEmpty ||
          _inputFields.isEmpty ||
          _selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณากรอกข้อมูลและเลือกรูปภาพให้ครบถ้วน')),
        );
        return;
      }

      // แสดง Animation รอโหลด
      _showUploadingAnimation(context);

      List<Map<String, dynamic>> items = [];
      for (int i = 0; i < itemControllers.length; i++) {
        items.add({
          'name': itemControllers[i].text,
          'amount': amountControllers[i].text,
        });
      }

      // อัปโหลดรูปทั้งหมด
      List<String> imageUrls = await _convertImagesToUrls(_selectedImages);

      // บันทึกข้อมูลลง Firestore
      await FirebaseFirestore.instance.collection('เก็บข้อมูลสิ่งของ').add({
        'date': DateFormat('dd/MM/yyyy').format(_selectedDate!),
        'location': _locationController.text,
        'items': items,
        'images': imageUrls,
        'title': widget.title,
      });

      // 🔹 เพิ่มโค้ดอัปเดต donated ใน cardของbanner
      await _updateDonatedCount(widget.title);

      // ปิด Animation รอโหลด
      Navigator.of(context).pop();

      // แสดง Animation สำเร็จ
      _showSuccessAnimation(context);
    } catch (e) {
      // ปิด Animation รอโหลด
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _updateDonatedCount(String title) async {
    try {
      var bannerQuery = await FirebaseFirestore.instance
          .collection('cardของbanner')
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (bannerQuery.docs.isNotEmpty) {
        var bannerDoc = bannerQuery.docs.first;
        var bannerRef = bannerDoc.reference;
        var currentDonated = (bannerDoc.data()['donated'] ?? 0).toInt();

        await bannerRef.update({
          'donated': currentDonated + 1, // 🔹 บวกเพิ่ม 1
        });
      } else {
        print('ไม่พบเอกสารที่ตรงกับ title: $title');
      }
    } catch (e) {
      print('Error updating donated count: $e');
    }
  }

  void _showUploadingAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
            'assets/images/Animation1.json',
            repeat: true,
          ),
        );
      },
    );
  }

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
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
            },
          ),
        );
      },
    );
  }
}
