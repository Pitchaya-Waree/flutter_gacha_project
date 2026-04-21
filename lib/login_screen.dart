import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showSmsWarning("กรุณากรอกข้อมูลให้ครบถ้วน");
    } else if (_userController.text != "admin" ||
        _passController.text != "1234") {
      _showSmsWarning("Username หรือ Password ไม่ถูกต้อง");
    } else {
      // ไปหน้าสุ่ม Gacha
    }
  }

  void _showSmsWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 10,
          right: 10,
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _handleLogin() async {
    String user = _userController.text;
    String pass = _passController.text;

    // 1. เช็คค่าว่างก่อน
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    // 2. ส่งข้อมูลไปที่ API
    try {
      var userData = await ApiService.login(user, pass);

      // 3. ถ้า Login ผ่าน แจ้งเตือนและพาไปหน้า Home
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ยินดีต้อนรับคุณ ${userData['user']['username']}'),
        ),
      );

      // คำสั่งเปลี่ยนหน้า
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      // 4. ถ้า Error (รหัสผิด)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username หรือ Password ไม่ถูกต้อง'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ฟังก์ชันภายในคลาส _LoginScreenState
Future<void> login() async {
  // 1. ระบุ URL ของ Vercel ที่คุณ Deploy API ไว้
  final String apiUrl = "https://api-your-project.vercel.app/login";

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _userController.text,
        "userpassword": _passController.text, // ต้องสะกดให้ตรงกับที่ API รอรับ
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Login สำเร็จ: เก็บข้อมูลผู้ใช้และเปลี่ยนหน้า
      print("ยินดีต้อนรับ: ${data['user']['username']}");
      // Navigator.pushReplacement(...)
    } else {
      // Login ไม่สำเร็จ: แสดง Warning SMS ตามที่ออกแบบไว้
      final errorData = jsonDecode(response.body);
      _showSmsWarning(errorData['message']);
    }
  } catch (e) {
    _showSmsWarning("ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text("เข้าสู่ระบบ"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text("สมัครสมาชิก"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
