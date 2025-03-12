import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'project_detail.dart';

class ProjectPage extends StatelessWidget {
  final List<String> image;
  final String title;
  final String description;
  final String phone;
  final String email;
  final String projectownername;
  final String banktype;
  final String banknumber;
  final String qrcodedonate;
  final String donationcenter;
  final String sendparcel;
  final String whatdonatething;
  final int donated;
  final int raisedAmount;
  final int remainingDays;
  final List<String> tags;
  final List<String> donatetype;

  const ProjectPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.phone,
    required this.email,
    required this.projectownername,
    required this.banktype,
    required this.banknumber,
    required this.qrcodedonate,
    required this.donationcenter,
    required this.sendparcel,
    required this.whatdonatething,
    required this.donated,
    required this.raisedAmount,
    required this.remainingDays,
    required this.tags,
    required this.donatetype,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: buildProjectContent(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when + button is pressed
        },
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomBar(
          selectedIndex: 0,
          onItemTapped: (index) {
            // Handle navigation from BottomBar
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
      ),
    );
  }

  Widget buildProjectContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 250,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: image.map((img) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        img,
                        fit: BoxFit.cover,
                        width: 300,
                        height: 200,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: tags.map((tag) => buildTag(tag)).toList(),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.green),
                    SizedBox(width: 10),
                    Text(phone),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.email, color: Colors.green),
                    SizedBox(width: 10),
                    Text(email),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProjectInfoBox(
                  icon: Icons.people_outline,
                  label: 'บริจาคแล้ว',
                  value: '$raisedAmount บาท / $donated คน',
                ),
                ProjectInfoBox(
                  icon: Icons.access_time,
                  label: 'คงเหลือ',
                  value: '$remainingDays วัน',
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailPage(
                      donatetype: donatetype,
                      title: title,
                      projectownername: projectownername,
                      banknumber: banknumber,
                      banktype: banktype,
                      qrcodedonate: qrcodedonate,
                      donationcenter: donationcenter,
                      sendparcel: sendparcel,
                      whatdonatething: whatdonatething,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  'บริจาค',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildTag(String tag) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }
}

class ProjectInfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProjectInfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.green),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
