import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _conPassController = TextEditingController();

  void _register() {
    String user = _userController.text;
    String pass = _passController.text;
    String conPass = _conPassController.text;

    if (user.isEmpty || pass.isEmpty || conPass.isEmpty) {
      _showPopup("กรุณากรอกข้อมูลให้ครบทุกช่อง");
    } else if (pass != conPass) {
      _showPopup("รหัสผ่านไม่ตรงกัน");
    } else {
      // Logic สมัครสมาชิกสำเร็จ
      _showPopup("สมัครสมาชิกสำเร็จ!");
    }
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("แจ้งเตือน"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ตกลง"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สมัครสมาชิก")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: _conPassController, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text("สมัครสมาชิก")),
          ],
        ),
      ),
    );
  }
}