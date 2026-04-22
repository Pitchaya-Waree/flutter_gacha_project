import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_profile_screen.dart'; // อย่าลืม import หน้า Profile ที่ทำไว้ก่อนหน้านี้

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> gamesData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGames(); // เรียกใช้ฟังก์ชันตอนเปิดหน้าจอ
  }

  Future<void> fetchGames() async {
    // เปลี่ยน URL ให้ตรงกับ Vercel ของคุณ (อย่าลืมเติม /api/games ต่อท้าย)
    final url = Uri.parse('https://api-ruddy-one-91.vercel.app/games');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          gamesData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Failed to load games');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gacha Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดงตอนกำลังโหลด
          : gamesData.isEmpty
          ? const Center(child: Text('ไม่มีเกมในระบบ'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              // แสดงผลรายการเกม
              child: ListView.builder(
                itemCount: gamesData.length,
                itemBuilder: (context, index) {
                  final game = gamesData[index];

                  final String avatarUrl = game['gameavatar'] ?? '';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      // === แก้ไขส่วน leading ตรงนี้ ===
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipOval(
                          // ทำให้รูปภาพเป็นวงกลม (ถ้าอยากได้สี่เหลี่ยมขอบมนให้เปลี่ยนเป็น ClipRRect)
                          child: Image.network(
                            // ดึง URL มาจากข้อมูล ถ้าข้อมูลเป็น null ให้ใส่เป็น String ว่างไว้ก่อน
                            game['gameavatar'] ?? '',
                            fit: BoxFit.cover, // ให้รูปภาพขยายเต็มกรอบพอดี
                            // --- วิธีเช็คและจัดการเมื่อภาพไม่ขึ้น (Error Builder) ---
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object exception,
                                  StackTrace? stackTrace,
                                ) {
                                  // โค้ดส่วนนี้จะทำงานก็ต่อเมื่อ: ลิงก์เสีย, ไม่มีเน็ต, หรือหาไฟล์ภาพไม่เจอ
                                  return Container(
                                    color: Colors
                                        .purple
                                        .shade50, // สีพื้นหลังสำรอง (คล้ายๆ ในรูปที่คุณแนบมา)
                                    child: const Icon(
                                      Icons.videogame_asset,
                                      size: 30,
                                      color: Colors.deepPurple, // สีไอคอนสำรอง
                                    ),
                                  );
                                },

                            // ---------------------------------------------------
                          ),
                        ),
                      ),
                      // ---------------------------------------------
                      title: Text(
                        game['gamename'] ?? 'Unknown Game',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Type: ${game['gametype'] ?? '-'}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print('กดเข้าเกม: ${game['gamename']}');
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
