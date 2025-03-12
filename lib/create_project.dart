import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class CreateProject extends StatefulWidget {
  @override
  _CreateProjectState createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDetailController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  List<File> _selectedImages = [];
  String? selectedTag;

  List<String> allTags = [
    "การศึกษา",
    "ทุนการศึกษา",
    "พัฒนาสถานศึกษาศาสนา",
    "บูรณะวัด",
    "กิจกรรมทางศาสนา",
    "สุขภาพ",
    "ช่วยเหลือผู้ป่วย",
    "อุปกรณ์การแพทย์",
    "เด็กและเยาวชน",
    "เด็กกำพร้า",
    "พัฒนาศักยภาพเด็ก",
    "ช่วยเหลือสัตว์",
    "สัตว์จรจัด",
    "ปกป้องสัตว์",
    "สิ่งแวดล้อม",
    "ปลูกป่า",
    "ฟื้นฟูธรรมชาติ",
    "ผู้ด้อยโอกาส",
    "ผู้พิการ",
    "ผู้สูงอายุ",
    "สาธารณภัย",
    "ช่วยเหลือผู้ประสบภัย",
    "บรรเทาภัยพิบัติ",
    "พัฒนาสังคม",
    "ชุมชน",
    "สร้างอาชีพ"
  ];

  List<String> selectedTags = [];

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDetailController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'สร้างโครงการ',
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
                  'สร้างโครงการ',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('ชื่อโครงการ',
                  controller: _projectNameController),
              SizedBox(height: 10),
              _buildTextField('รายละเอียดโครงการ',
                  controller: _projectDetailController, maxLines: 5),
              SizedBox(height: 10),
              _buildTextField('อีเมล', controller: _emailController),
              SizedBox(height: 10),
              _buildTextField('เบอร์โทรศัพท์', controller: _phoneController),
              SizedBox(height: 10),
              _buildTextField('จำนวนเงินที่โครงการตั้งเป้าไว้',
                  controller: _targetAmountController),
              SizedBox(height: 20),
              _buildTagDropdown(),
              SizedBox(height: 20),
              _buildDatePickerField(
                  'วันเริ่มโครงการ', _startDateController, true),
              SizedBox(height: 20),
              _buildDatePickerField(
                  'วันสิ้นสุดโครงการ', _endDateController, false),
              SizedBox(height: 20),
              Text(
                'รูปที่เกี่ยวกับโครงการ',
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
                  onPressed: () => _navigateToNextScreen(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'ถัดไป',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText,
      {int maxLines = 1, required TextEditingController controller}) {
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
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            hintText: labelText,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
      String labelText, TextEditingController controller, bool isStartDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'เลือกวันที่',
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
        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        if (isStartDate) {
          _startDateController.text = formattedDate;
        } else {
          // ตรวจสอบให้วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่ม
          DateTime? startDate = _startDateController.text.isNotEmpty
              ? DateFormat('dd/MM/yyyy').parse(_startDateController.text)
              : null;

          if (startDate != null && picked.isBefore(startDate)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('วันที่สิ้นสุดต้องมากกว่าวันเริ่มต้น')),
            );
          } else {
            _endDateController.text = formattedDate;
          }
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

  void _navigateToNextScreen(BuildContext context) {
    DateTime? parsedStartDate;
    DateTime? parsedEndDate;

    if (_startDateController.text.isNotEmpty) {
      parsedStartDate =
          DateFormat('dd/MM/yyyy').parse(_startDateController.text);
    }

    if (_endDateController.text.isNotEmpty) {
      parsedEndDate = DateFormat('dd/MM/yyyy').parse(_endDateController.text);
    }

    int? targetAmount =
        int.tryParse(_targetAmountController.text); // ✅ แปลงเป็นตัวเลข

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextScreen(
          projectname: _projectNameController.text,
          projectdetail: _projectDetailController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          targetamount: targetAmount, // ✅ ส่งเป็นตัวเลข
          tags: selectedTags,
          startdate: parsedStartDate, // ✅ ส่งค่า Timestamp ที่ถูกต้อง
          enddate: parsedEndDate,
          image: _selectedImages,
        ),
      ),
    );
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

  Widget _buildTagDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "เลือก Tags ที่เกี่ยวข้องกับโครงการ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: Text("เลือก Tags"),
          value: null, // ✅ ไม่ต้องใช้ selectedTag เพราะเป็นหลายตัวเลือก
          isExpanded: true,
          items: allTags.map((tag) {
            return DropdownMenuItem<String>(
              value: tag,
              child: Text(tag),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null && !selectedTags.contains(newValue)) {
              setState(() {
                selectedTags.add(newValue); // ✅ เพิ่ม Tag ที่เลือกลงไป
              });
            }
          },
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: selectedTags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  selectedTags.remove(tag); // ✅ ลบ Tag ที่เลือกออก
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class NextScreen extends StatefulWidget {
  final String projectname;
  final String projectdetail;
  final String email;
  final String phone;
  final num? targetamount;
  final List<String> tags;
  final DateTime? startdate;
  final DateTime? enddate;
  final List<File> image;
  NextScreen({
    required this.projectname,
    required this.projectdetail,
    required this.email,
    required this.phone,
    this.targetamount,
    required this.tags,
    required this.startdate,
    required this.enddate,
    required this.image,
  });
  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  List<String> donateType = []; // ✅ เก็บประเภทการบริจาคที่ผู้ใช้เลือก

  final TextEditingController projectOwnerController = TextEditingController();
  final TextEditingController bankTypeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController donationPlaceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController donationItemsController = TextEditingController();

  File? qrCodeImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            'ช่องทางการรับบริจาค',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: _buildCheckboxTitle('รับบริจาคเงิน'),
                value: donateType.contains('บริจาคเงิน'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      donateType.add('บริจาคเงิน');
                    } else {
                      donateType.remove('บริจาคเงิน');
                    }
                  });
                },
              ),
              if (donateType.contains('บริจาคเงิน')) ...[
                _buildTextField('ชื่อเจ้าของโครงการ', projectOwnerController),
                _buildTextField('ประเภทธนาคาร', bankTypeController),
                _buildTextField('หมายเลขบัญชี', accountNumberController),
                SizedBox(height: 10),
                Text('รูปคิวอาร์โค้ดสำหรับสแกนเงิน',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildImageUploader(),
              ],
              CheckboxListTile(
                title: _buildCheckboxTitle('รับบริจาคพัสดุ'),
                value: donateType.contains('บริจาคสิ่งของ'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      donateType.add('บริจาคสิ่งของ');
                    } else {
                      donateType.remove('บริจาคสิ่งของ');
                    }
                  });
                },
              ),
              if (donateType.contains('บริจาคสิ่งของ')) ...[
                _buildTextField(
                    'สถานที่ที่สามารถมาบริจาคได้', donationPlaceController,
                    maxLines: 5),
                _buildTextField('ที่อยู่ที่จะส่งพัสดุ', addressController,
                    maxLines: 5),
                _buildTextField('รับบริจาคอะไรบ้าง', donationItemsController,
                    maxLines: 5),
              ],
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('สร้างโครงการ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),);
  }

  Widget _buildCheckboxTitle(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.green, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
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
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              hintText: labelText),
        ),
      ],
    );
  }

  Widget _buildImageUploader() {
    return qrCodeImage == null
        ? GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
            ),
          )
        : Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(qrCodeImage!,
                    fit: BoxFit.cover, width: double.infinity, height: 150),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => setState(() => qrCodeImage = null),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
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
      setState(() => qrCodeImage = File(pickedFile.path));
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> images) async {
    List<String> downloadUrls = [];
    final String cloudName = 'dea5tmnil'; // ✅ ตรวจสอบ Cloud Name
    final String uploadPreset = 'ข้อมูลโครงการ'; // ✅ ตรวจสอบ Upload Preset

    for (File image in images) {
      final Uri apiUrl =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final bytes = await image.readAsBytes();

      var request = http.MultipartRequest('POST', apiUrl)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: image.path.split('/').last));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print(
          "Cloudinary Response: $responseData"); // ✅ ดู response จาก Cloudinary

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        downloadUrls.add(data['secure_url']); // ✅ ดึง URL ที่อัปโหลดสำเร็จ
      } else {
        throw Exception(
            'Upload Error: ${response.statusCode} - $responseData'); // ✅ แสดง error ที่ชัดเจน
      }
    }
    return downloadUrls;
  }

  Future<void> _submitDonation() async {
    _showUploadingAnimation(); // ✅ แสดง Animation โหลด

    try {
      String? qrCodeUrl;
      if (qrCodeImage != null) {
        qrCodeUrl = await _convertImageToUrl(qrCodeImage!);
      }

      // 📌 ใช้ Cloudinary ในการอัปโหลดรูป
      List<String> imageUrls = await _uploadImagesToCloudinary(widget.image);

      await FirebaseFirestore.instance.collection('cardของbanner').add({
        'title': widget.projectname,
        'description': widget.projectdetail,
        'email': widget.email,
        'phone': widget.phone,
        'targetAmount': widget.targetamount,
        'tags': widget.tags,
        'startday': widget.startdate,
        'endday': widget.enddate,
        'image': imageUrls,
        'projectownername': projectOwnerController.text,
        'banktype': bankTypeController.text,
        'banknumber': accountNumberController.text,
        'donationcenter': donationPlaceController.text,
        'sendparcel': addressController.text,
        'whatdonatething': donationItemsController.text,
        'qrcodedonate': qrCodeUrl,
        'donatetype': donateType,
        'status': "เปิดรับบริจาคอยู่",
        'donated': 0,
        'raisedAmount': 0,
        'date': DateTime.now().toString(),
      });

      Navigator.of(context).pop(); // ✅ ปิด Animation โหลด
      _showSuccessAnimation(); // ✅ แสดงอนิเมชั่นสำเร็จ
    } catch (e) {
      Navigator.of(context).pop(); // ✅ ปิด Animation โหลดเมื่อเกิดข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<String> _convertImageToUrl(File imageFile) async {
    final String cloudName = 'dea5tmnil'; // ✅ ตรวจสอบ Cloud Name
    final String uploadPreset = 'ข้อมูลโครงการ'; // ✅ ตรวจสอบ Upload Preset
    final Uri apiUrl =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    _showUploadingAnimation(); // ✅ แสดง Animation ขณะอัปโหลด

    try {
      final bytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest('POST', apiUrl)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: imageFile.path.split('/').last));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      Navigator.of(context).pop(); // ✅ ปิด Loading Animation

      print("Cloudinary Response: $responseData"); // ✅ ดู Response ที่ส่งกลับมา

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return data['secure_url'];
      } else {
        throw Exception('Upload Error: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      Navigator.of(context).pop(); // ✅ ปิด Loading Animation ถ้าเกิด error
      print("Error uploading image: $e"); // ✅ แสดง Error
      return '';
    }
  }

  void _showUploadingAnimation() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: Lottie.asset('assets/images/Animation1.json')));
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset('assets/images/Animation2.json',
            onLoaded: (composition) {
          Future.delayed(composition.duration,
              () => Navigator.of(context).popUntil((route) => route.isFirst));
        }),
      ),
    );
  }
}
