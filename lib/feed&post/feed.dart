import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../bottom_bar.dart';
import 'post_detail.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final CollectionReference _feedCollection =
      FirebaseFirestore.instance.collection('feed');
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'th_TH'; // ตั้งค่าให้แสดงวันที่เป็นภาษาไทย
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/notification');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed'), backgroundColor: Colors.green),
      body: StreamBuilder<QuerySnapshot>(
        stream: _feedCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var feedDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: feedDocs.length,
            itemBuilder: (context, index) {
              final data = feedDocs[index].data() as Map<String, dynamic>;

              print("Feed Data: $data");

              // ใช้ข้อมูลจาก feed เลย
              String fullName = '${data['firstName'] ?? 'ไม่ระบุ'} ${data['lastName'] ?? ''}';
              String formattedTimestamp = data['created_at'] != null
                  ? DateFormat('d MMMM yyyy HH:mm', 'th').format(
                      (data['created_at'] as Timestamp).toDate())
                  : 'ไม่ระบุเวลา';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPostScreen(postId: feedDocs[index].id),
                    ),
                  );
                },
                child: PostWidget(
                  postId: feedDocs[index].id,
                  username: fullName,
                  imageUrl: data['image'] is List
                      ? data['image'].first
                      : (data['image'] ?? 'ไม่มีนูปภาพ'),
                  location:
                      "ชื่อกิจกรรม: ${data['ActivityName'] ?? 'ไม่ระบุ'}",
                  description: data['Activitydetail'] ?? 'ไม่มีรายละเอียด',
                  timestamp: formattedTimestamp,
                  likeCount: data['likes'] ?? 0,
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post');
        },
        backgroundColor: Colors.green,
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


class PostWidget extends StatefulWidget {
  final String postId;
  final String username;
  final String imageUrl;
  final String location;
  final String description;
  final String timestamp;
  final int likeCount;

  PostWidget({
    required this.postId,
    required this.username,
    required this.imageUrl,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.likeCount,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int likes = 0;

  @override
  void initState() {
    super.initState();
    likes = widget.likeCount;
  }

  void _likePost() async {
    setState(() {
      likes += 1;
    });
    await FirebaseFirestore.instance
        .collection('feed')
        .doc(widget.postId)
        .update({'likes': likes});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle, size: 40, color: Colors.grey[700]),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        widget.timestamp,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.imageUrl, fit: BoxFit.cover),
            ),
            SizedBox(height: 10),
            Text(
              widget.location,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _likePost,
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.blue),
                      SizedBox(width: 5),
                      Text('$likes'),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey[600]),
                  onPressed: () {
                    print("แชร์โพสต์ ${widget.postId}");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
