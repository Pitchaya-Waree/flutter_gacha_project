import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<dynamic> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    // เปลี่ยน URL นี้เป็น URL API Vercel ของคุณ
    final url = Uri.parse('https://api-ruddy-one-91.vercel.app/gacha');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          historyData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // สามารถเพิ่มการจัดการ Error ตรงนี้ได้
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: Text('User', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ส่วนโปรไฟล์ผู้ใช้
            const CircleAvatar(
              radius: 50,
              child: Text('user', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // กรอบประวัติการสุ่ม Gacha
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Gacha History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.black54),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : historyData.isEmpty
                          ? const Center(child: Text('ไม่มีประวัติการสุ่ม'))
                          : ListView.builder(
                              itemCount: historyData.length,
                              itemBuilder: (context, index) {
                                final item = historyData[index];
                                return ListTile(
                                  leading: const Icon(
                                    Icons.stars,
                                    color: Colors.amber,
                                  ),
                                  title: Text(
                                    '${item['gamename']} - ${item['itemname']}',
                                  ),
                                  subtitle: Text(
                                    'Rarity: ${item['itemrarity']}',
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
