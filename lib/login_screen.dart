import 'package:flutter/material.dart';
import 'register_screen.dart'; // Import ไฟล์ที่แยกออกมา

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
    } else if (_userController.text != "admin" || _passController.text != "1234") {
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
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100, left: 10, right: 10),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _login, child: const Text("เข้าสู่ระบบ")),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
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
