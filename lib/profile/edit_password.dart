import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPasswordScreen extends StatefulWidget {
  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in');
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        print('No user data found in Firestore');
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      print('User Data: $data');

      setState(() {
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _updatePassword() async {
  String newPassword = passwordController.text.trim();
  String confirmPassword = confirmPasswordController.text.trim();

  if (newPassword.isEmpty || confirmPassword.isEmpty) {
    _showMessage('Please fill in both password fields.');
    return;
  }

  if (newPassword != confirmPassword) {
    _showMessage('Passwords do not match.');
    return;
  }

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
      _showMessage('Password updated successfully.');
      Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
    } else {
      _showMessage('No user is logged in.');
    }
  } catch (e) {
    _showMessage('Error updating password: $e');
  }
}


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('New Password', passwordController, isPassword: true),
              const SizedBox(height: 20),
              _buildTextField('Confirm Password', confirmPasswordController,
                  isPassword: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Update Password',style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: isPassword, // ซ่อนข้อความถ้าเป็นรหัสผ่าน
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white, // พื้นหลังสีขาว
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), // ความโค้งของกรอบ
            borderSide: const BorderSide(
              color: Colors.black, // สีกรอบ
              width: 1.0, // ความหนาของกรอบ
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.black, // สีกรอบเมื่อไม่ได้โฟกัส
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.black, // สีกรอบเมื่อโฟกัส
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}

}
