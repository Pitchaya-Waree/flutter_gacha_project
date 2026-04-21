import 'package:flutter/material.dart';
import 'home.dart';
void main() => runApp(const GachaApp());

class GachaApp extends StatelessWidget {
  const GachaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WelcomeScreen());
  }
}