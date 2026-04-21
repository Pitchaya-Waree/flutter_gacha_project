import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ เปลี่ยน URL นี้ให้เป็น URL ของ Vercel ที่คุณ Deploy Backend ไว้
  static const String baseUrl = 'https://your-api-url.vercel.app';

  // --------------------------------------------------
  // 1. API สำหรับ Login
  // --------------------------------------------------
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'userpassword': password, 
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // ส่งข้อมูล User กลับไป
    } else {
      throw Exception('เข้าสู่ระบบไม่สำเร็จ');
    }
  }

  // --------------------------------------------------
  // 2. API สำหรับดึงข้อมูลเกมในหน้าหลัก
  // --------------------------------------------------
  static Future<List<dynamic>> fetchGames() async {
    final response = await http.get(Uri.parse('$baseUrl/games'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('โหลดข้อมูลเกมไม่สำเร็จ');
    }
  }

  // --------------------------------------------------
  // 3. API สำหรับสุ่มไอเท็ม (Gacha Roll)
  // --------------------------------------------------
  static Future<Map<String, dynamic>> rollGacha(int userId, int gameId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/roll-gacha'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'game_id': gameId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body); // ส่งข้อมูลไอเท็มที่สุ่มได้กลับไป
    } else {
      throw Exception('เกิดข้อผิดพลาดในการสุ่ม');
    }
  }
}