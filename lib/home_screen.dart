import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List games = [];
  bool isLoading = true; // เพิ่มตัวแปรสำหรับเช็คสถานะการโหลด

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  // ฟังก์ชันดึงข้อมูลจาก Express.js API
  Future<void> fetchGames() async {
    try {
      final response = await http.get(Uri.parse('https://api-ruddy-one-91.vercel.app/games'));
      if (response.statusCode == 200) {
        setState(() {
          games = json.decode(response.body);
          isLoading = false; // โหลดเสร็จแล้ว ปิดตัวโหลด
        });
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการดึงข้อมูล: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: fetchGames, // กดเพื่อรีเฟรชข้อมูล
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // TODO: นำทางไปหน้าประวัติการสุ่ม
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                // ใส่รูป Avatar จำลอง หรือดึงจาก URL ของ User
                backgroundImage: NetworkImage('https://robohash.org/avatar.png'),
              ),
            ),
          ),
        ],
      ),
      // แสดงวงกลมโหลดข้อมูล ถ้าโหลดเสร็จค่อยแสดง List
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : games.isEmpty
              ? const Center(child: Text("ยังไม่มีข้อมูลเกมในระบบ"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Card(
                      elevation: 4, // เพิ่มเงาให้การ์ดดูมีมิติ
                      margin: const EdgeInsets.only(bottom: 15),
                      // ใช้ ClipRRect ตัดขอบการ์ดให้โค้งมน
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // 🌟 ป้องกัน Error RenderFlex
                        crossAxisAlignment: CrossAxisAlignment.stretch, // 🌟 ขยายรูปให้เต็มการ์ดอย่างปลอดภัย
                        children: [
                          // ส่วนแสดงรูปภาพ
                          Image.network(
                            game['game_image'] ?? '', // ถ้าไม่มี URL ให้เป็น String ว่าง
                            height: 200,
                            fit: BoxFit.cover,
                            // 🌟 ระบบป้องกัน: ถ้ารูปโหลดไม่ขึ้น หรือลิ้งค์เสีย จะไม่ Error แดง แต่โชว์กล่องสีเทาแทน
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              );
                            },
                          ),
                          // ส่วนแสดงชื่อเกม
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              game['game_name'] ?? 'ไม่ทราบชื่อเกม',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: นำทางไปหน้าสุ่ม Gacha
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}