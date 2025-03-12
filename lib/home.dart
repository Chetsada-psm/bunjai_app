import 'package:bunjai_app/create_project.dart';
import 'package:bunjai_app/feed&post/create_post.dart';
import 'package:bunjai_app/follow_progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? role;
  final CollectionReference _projects =
      FirebaseFirestore.instance.collection('cardของbanner');
  final PageController _pageController = PageController();
  Timer? _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(3); // Set the number of pages (example uses 3)
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ใช้ ?. เพื่อป้องกันกรณีที่ _timer เป็น null
    _pageController.dispose();
    super.dispose();
  }

  void _fetchUserRole() async {
    try {
      // ดึงผู้ใช้งานปัจจุบันจาก FirebaseAuth
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // ดึงข้อมูลจาก Firestore โดยใช้อีเมล
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email',
                isEqualTo: currentUser.email) // ใช้อีเมลของผู้ใช้งาน
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          print("User data: ${userDoc.data()}");
          setState(() {
            role = userDoc['role']; // ตั้งค่า role
          });
        } else {
          print("User not found in Firestore");
          setState(() {
            role = null; // กรณีไม่พบข้อมูล
          });
        }
      } else {
        print("No user logged in");
        setState(() {
          role = null; // กรณีไม่มีผู้ใช้งานล็อกอิน
        });
      }
    } catch (e) {
      print("Error fetching role: $e");
      setState(() {
        role = null; // กรณีเกิดข้อผิดพลาด
      });
    }
  }

  void _startAutoScroll(int totalPages) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _pageController.page != null) {
        int currentPage = _pageController.page!.round();
        int nextPage = currentPage + 1;

        // If last page is reached, scroll back to the first page
        if (nextPage >= totalPages) {
          _pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 60, 202, 65),
        // // leading: IconButton(
        // //   icon: Icon(Icons.menu),
        // //   color: Colors.white,
        // //   onPressed: () {},
        // // ),
        // // actions: [
        // //   IconButton(
        // //     icon: Icon(Icons.search),
        // //     color: Colors.white,
        // //     onPressed: () {},
        // //   ),
        // ],
      ),
      backgroundColor: Color.fromARGB(255, 59, 196, 64),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: _projects.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error Loading Data'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No Projects Available'),
              );
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;

            // Filter card1 (donated > 100)
            List<DocumentSnapshot> filteredDocs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['donated'] ?? 0) > 50;
            }).toList();

            return Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 2.0),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/images/bg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 50),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 160,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 170),
                  child: Text(
                    "บุญใจ",
                    style: TextStyle(fontSize: 50, color: Colors.white),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 100, left: 170),
                  child: Text(
                    '"ให้รัก ให้ความสุข      ให้ชีวิต ให้ความหวัง   ให้แรงบันดาลใจ"',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 240, left: 30),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // จัดตำแหน่งให้อยู่ทางซ้าย
                    children: [
                      // ปุ่ม "ติดตามความคืบหน้า"
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10), // ระยะห่างระหว่างปุ่ม
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowProgressScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.access_time,
                            size: 37,
                          ),
                          label: const Text(
                            'ติดตามความคืบหน้า',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.green,
                            backgroundColor: Colors.white,
                            minimumSize:
                                const Size(200, 45), // ขนาดปุ่มให้เท่ากัน
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      // ปุ่ม "สร้างโครงการ" (แสดงเฉพาะ role == 'foundation')
                      if (role == 'foundation') ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProject()));
                          },
                          icon: const Icon(Icons.add, size: 30),
                          label: const Text(
                            'สร้างโครงการ',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.green,
                            backgroundColor: Colors.white,
                            minimumSize:
                                const Size(200, 45), // ขนาดปุ่มให้เท่ากัน
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 420,
                  left: 25,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recommended project',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('See more'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.42,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final data = filteredDocs[index].data()
                                as Map<String, dynamic>;
                            final tags = (data['tags'] as List<dynamic>? ?? [])
                                .cast<String>();
                            final donatetype =
                                (data['donatetype'] as List<dynamic>? ?? [])
                                    .cast<String>();
                            final Image =
                                (data['image'] as List<dynamic>? ?? [])
                                    .cast<String>();

                            return buildDonationCard(
                              image: Image,
                              donationcenter: data['donationcenter'],
                              sendparcel: data['sendparcel'],
                              title: data['title'] ?? 'Unknown Title',
                              description: data['description'] ??
                                  'No description available',
                              projectownername: data['projectownername'] ??
                                  'No ProjectOwerName',
                              whatdonatething: data['whatdonatething'] ??
                                  'No whatdonatething',
                              banktype: data['banktype'] ?? 'No banktype',
                              banknumber: data['banknumber'] ?? 'No banknumber',
                              qrcodedonate:
                                  data['qrcodedonate'] ?? ' No qrcodedonate',
                              targetAmount: data['targetAmount'] ?? 0,
                              raisedAmount: data['raisedAmount'] ?? 0,
                              tags: tags,
                              donatetype: donatetype,
                              donated: data['donated'] ?? 0,
                              phone: data['phone'] ?? 'No phone',
                              email: data['email'] ?? 'No email',
                              startday: (data['startday']as Timestamp).toDate(),
                              endday: (data['endday']as Timestamp).toDate(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CategoryChip(label: 'All', isSelected: true),
                            CategoryChip(label: 'health'),
                            CategoryChip(label: 'food'),
                            CategoryChip(label: 'nature'),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Project for you',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('See more'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('cardของbanner')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error loading projects'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No projects available'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs
                                .take(4)
                                .length, // จำกัด 4 รายการ
                            itemBuilder: (context, index) {
                              final data = snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                              final tags =
                                  (data['tags'] as List<dynamic>? ?? [])
                                      .cast<String>();
                              final donatetype =
                                  (data['donatetype'] as List<dynamic>? ?? [])
                                      .cast<String>();
                              final Image =
                                  (data['image'] as List<dynamic>? ?? [])
                                      .cast<String>();

                              return buildDonationCard2(
                                context: context,
                                donationcenter: data['donationcenter'] ??
                                    'No donationcenter',
                                sendparcel:
                                    data['sendparcel'] ?? 'No sendparcel',
                                image: Image,
                                title: data['title'] ?? 'Untitled Project',
                                phone: data['phone'] ?? 'No phone',
                                email: data['email'] ?? 'No email',
                                projectownername: data['projectownername'] ??
                                    'No projectownername',
                                whatdonatething: data['whatdonatething'] ??
                                    'No whatdonatething',
                                banktype: data['banktype'] ?? 'No banktype',
                                banknumber:
                                    data['banknumber'] ?? 'No banknumber',
                                description: data['description'] ??
                                    'No description available',
                                qrcodedonate:
                                    data['qrcodedonate'] ?? ' No qrcodedonate',
                                donated: data['donated'] ?? 0,
                                targetAmount: data['targetAmount'] ?? 0,
                                raisedAmount: data['raisedAmount'] ?? 0,
                                tags: tags,
                                donatetype: donatetype,
                                startday: (data['startday']as Timestamp).toDate(),
                                endday: (data['endday']as Timestamp).toDate(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost()),
          );
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
        child: BottomBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildDonationCard({
  required List<String> image,
  required String phone,
  required String email,
  required String title,
  required String description,
  required String projectownername,
  required String banktype,
  required String banknumber,
  required String qrcodedonate,
  required String donationcenter,
  required String sendparcel,
  required String whatdonatething,
  required dynamic donated,
  required dynamic targetAmount,
  required dynamic raisedAmount,
  required List<String> tags,
  required List<String> donatetype,
  required DateTime startday,
  required DateTime endday,
}) {
  // ✅ คำนวณจำนวนวันคงเหลือ
  int remainingDays = endday.difference(DateTime.now()).inDays;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectPage(
            image: image,
            title: title,
            description: description,
            phone: phone,
            email: email,
            projectownername: projectownername,
            donationcenter: donationcenter,
            sendparcel: sendparcel,
            whatdonatething: whatdonatething,
            banknumber: banknumber,
            banktype: banktype,
            qrcodedonate: qrcodedonate,
            donated: (donated is int) ? donated : int.tryParse(donated.toString()) ?? 0,
            raisedAmount: (raisedAmount is int) ? raisedAmount : int.tryParse(raisedAmount.toString()) ?? 0,
            remainingDays: remainingDays, // ✅ ใช้ค่าที่คำนวณได้
            tags: tags,
            donatetype: donatetype,
          ),
        ),
      );
    },
    child: Card(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image.isNotEmpty && image.first.startsWith('http')
                ? Image.network(image.first, height: 170, fit: BoxFit.cover)
                : Container(
                    height: 220,
                    color: Colors.grey,
                    child: Center(child: Text('No Image Available')),
                  ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 5),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: targetAmount > 0
                    ? (raisedAmount / targetAmount).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 11,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${raisedAmount.toString()} บาท / ${targetAmount.toString()} บาท',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '$remainingDays days left', // ✅ แสดงผลค่าที่คำนวณได้
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

}

Widget buildDonationCard2({
  required BuildContext context,
  required List<String> image,
  required String title,
  required String email,
  required String phone,
  required String projectownername,
  required String banktype,
  required String banknumber,
  required String description,
  required String qrcodedonate,
  required String donationcenter,
  required String whatdonatething,
  required String sendparcel,
  required dynamic donated,
  required dynamic targetAmount,
  required dynamic raisedAmount,
  required List<String> tags,
  required List<String> donatetype,
  required DateTime startday,
  required DateTime endday,
}) {
  int remainingDays = endday.difference(DateTime.now()).inDays;
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectPage(
            image: image,
            title: title,
            description: description,
            phone: phone,
            email: email,
            projectownername: projectownername,
            banknumber: banknumber,
            banktype: banktype,
            qrcodedonate: qrcodedonate,
            donationcenter: donationcenter,
            sendparcel: sendparcel,
            whatdonatething: whatdonatething,
            donated: (donated is int)
                ? donated
                : int.tryParse(donated.toString()) ?? 0,
            raisedAmount: (raisedAmount is int)
                ? raisedAmount
                : int.tryParse(raisedAmount.toString()) ?? 0,
            remainingDays: remainingDays, // ✅ ใช้ค่าที่คำนวณได้
            tags: tags,
            donatetype: donatetype,
          ),
        ),
      );
    },
    child: Stack(
      children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // Image Section
                image.isNotEmpty && image.first.startsWith('http')
                    ? Image.network(
                        image.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: Center(
                          child: Text(
                            'No Image',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                SizedBox(width: 10),
                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      // Description
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: targetAmount > 0
                              ? (raisedAmount / targetAmount).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // Raised Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${raisedAmount.toString()} บาท / ${targetAmount.toString()} บาท',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                      // Tags Section
                      Wrap(
                        children: tags
                            .map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(
                                    tag,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.green.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Positioned Section for remaining days
        Positioned(
          top: 5,
          left: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '$remainingDays days left',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    ),
  );
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  CategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle category selection
        },
        selectedColor: Colors.green,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.green,
        ),
        backgroundColor: Colors.green.shade100,
      ),
    );
  }
}
