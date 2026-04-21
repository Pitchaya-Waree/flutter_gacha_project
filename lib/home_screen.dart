import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List games = []; // ตัวแปรเก็บข้อมูลเกมจากฐานข้อมูล

  @override
  void initState() {
    super.initState();
    fetchGames(); // ดึงข้อมูลทันทีที่เปิดหน้าจอ
  }

  // ฟังก์ชันดึงข้อมูลจาก Express.js API
  Future<void> fetchGames() async {
    final response = await http.get(Uri.parse('https://your-api.vercel.app/games'));
    if (response.statusCode == 200) {
      setState(() {
        games = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => fetchGames(), // กด Home เพื่อ Refresh ข้อมูล
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // ไปหน้าประวัติการสุ่ม (User Profile)
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage('URL_รูป_USER'),
              ),
            ),
          ),
        ],
      ),
      body: games.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: games.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      // ล็อคขนาดรูปภาพให้เท่ากันทุกใบ
                      Image.network(
                        games[index]['game_image'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          games[index]['game_name'],
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
          // ไปหน้าสุ่ม Gacha
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}