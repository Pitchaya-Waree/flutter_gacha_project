import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const GachaApp());
}

class GachaApp extends StatelessWidget {
  const GachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gacha Game',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const WelcomeScreen(),
    );
  }
}

// หน้าแรก (Welcome Screen)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gacha game',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // คำสั่งนำทางไปยังหน้า Login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('เข้าสู่ระบบ'),
            ),
          ],
        ),
      ),
    );
  }
}
