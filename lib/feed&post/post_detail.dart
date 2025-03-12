import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPostScreen extends StatefulWidget {
  final String postId;

  DetailPostScreen({required this.postId});

  @override
  _DetailPostScreenState createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  DocumentSnapshot? postSnapshot;
  bool isLoading = true;
  int likeCount = 0;
  List<Map<String, dynamic>> comments = [];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  void _fetchPostData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .get();

      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? postData =
            snapshot.data() as Map<String, dynamic>?;

        List<Map<String, dynamic>> updatedComments = [];
        for (var doc in commentSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;

          if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
            Timestamp timestamp = data['timestamp'] as Timestamp;
            String formattedDate = _formatTimestamp(timestamp);
            updatedComments.add({...data, 'formattedDate': formattedDate});
          } else {
            updatedComments.add({...data, 'formattedDate': 'ไม่ทราบเวลา'});
          }
        }

        setState(() {
          postSnapshot = snapshot;
          likeCount = postData?['likes'] ?? 0;
          comments = updatedComments;
        });
      }
    } catch (e) {
      print("Error fetching post: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String formatActivityDate(dynamic activityDate) {
    if (activityDate == null) return "-";

    DateTime date;

    // กรณี Firestore ให้มาเป็น Timestamp
    if (activityDate is Timestamp) {
      date = activityDate.toDate();
    }
    // กรณีเป็น String (ISO 8601)
    else if (activityDate is String) {
      try {
        date = DateTime.parse(activityDate);
      } catch (e) {
        return "-"; // ถ้าแปลงไม่ได้ ให้คืนค่า "-"
      }
    }
    // ถ้าเป็น DateTime อยู่แล้ว
    else if (activityDate is DateTime) {
      date = activityDate;
    } else {
      return "-";
    }

    // ใช้ DateFormat สำหรับแสดงวันที่เป็นภาษาไทย
    var formatter = DateFormat("d MMMM yyyy", "th_TH");
    return formatter.format(date);
  }

  void _likePost() async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('feed').doc(widget.postId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(postRef);

        if (!snapshot.exists) return;

        int currentLikes = (snapshot['likes'] ?? 0) as int;
        transaction.update(postRef, {'likes': currentLikes + 1});
      });

      // อัพเดทค่าไลก์ใน UI หลังจาก Transaction สำเร็จ
      setState(() {
        likeCount += 1;
      });
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  void _addComment() async {
    if (commentController.text.trim().isEmpty) return;

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      print("Error: User not logged in");
      return;
    }

    try {
      // ดึงข้อมูลผู้ใช้จาก Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        print("Error: User data does not exist");
        return;
      }

      var userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData == null) {
        print("Error: User data is null");
        return;
      }

      String firstName = userData['firstName'] ?? 'ไม่ระบุชื่อ';
      String lastName = userData['lastName'] ?? '';

      // ใช้ Timestamp.now() ในการบันทึกเวลา
      Map<String, dynamic> newComment = {
        'firstName': firstName,
        'lastName': lastName,
        'text': commentController.text,
        'timestamp':
            Timestamp.fromDate(DateTime.now()), // แปลง DateTime เป็น Timestamp
      };

      // เพิ่มคอมเมนต์ลงใน Firestore
      await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .collection('comments')
          .add(newComment);

      setState(() {
        comments.insert(0, {
          ...newComment,
          'formattedDate': _formatTimestamp(newComment['timestamp'])
        });
        commentController.clear(); // เคลียร์ข้อความในช่องคอมเมนต์
      });
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Post Detail')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (postSnapshot == null || !postSnapshot!.exists) {
      return Scaffold(
        appBar: AppBar(title: Text('Post Detail')),
        body: Center(child: Text("ไม่พบโพสต์นี้")),
      );
    }
    Map<String, dynamic>? postData =
        postSnapshot?.data() as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: Colors.purple[100]),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${postData?['firstName'] ?? 'ไม่ระบุชื่อ'} ${postData?['lastName'] ?? ''}"
                              .trim()
                              .isEmpty
                          ? 'ไม่ระบุชื่อ'
                          : "${postSnapshot!['firstName']} ${postSnapshot!['lastName']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "วันที่เริ่ม: ${formatActivityDate(postSnapshot!['ActivityStartDate'])}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),
            // Post Image
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (postSnapshot?['image'] is List &&
                        postSnapshot?['image'].isNotEmpty)
                    ? Image.network(
                        postSnapshot?['image'][0]) // ดึงรูปแรกจาก List
                    : Image.asset('assets/no_image.png')),

            SizedBox(height: 12),
            // Post Description
            Text(
              "ชื่อกิจกรรม : ${postSnapshot!['ActivityName'] ?? 'ไม่ระบุชื่อกิจกรรม'} ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              postSnapshot!['Activitydetail'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            // Like, Comment, Share Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _likePost,
                      child: Icon(Icons.thumb_up, color: Colors.blue),
                    ),
                    SizedBox(width: 5),
                    Text('$likeCount'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.grey[600]),
                    SizedBox(width: 5),
                    Text('${comments.length} ความคิดเห็น'),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey[600]),
                  onPressed: () {
                    print("แชร์โพสต์ ${widget.postId}");
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            // Comment Section
            Text("ความคิดเห็น",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            for (var comment in comments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius: 15, backgroundColor: Colors.purple[100]),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ แสดงชื่อ firstName + lastName ถ้ามี
                          Text(
                            "${comment['firstName'] ?? 'ไม่ระบุชื่อ'} ${comment['lastName'] ?? ''}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(comment['text'] ?? '',
                                style: TextStyle(fontSize: 14)),
                          ),
                          // ✅ แสดงเวลาคอมเมนต์
                          Text(
                            comment['formattedDate'] ?? 'ไม่ทราบเวลา',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 10),
            // Add Comment Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "เขียนความคิดเห็น...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
