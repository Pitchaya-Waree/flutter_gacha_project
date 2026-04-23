import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'user_profile_screen.dart'; 
// หากต้องการให้ไอคอน User กดแล้วไปหน้า User Profile ให้ import หน้า User Profile มาด้วย
// import 'user_profile_screen.dart'; 

class GachaScreen extends StatefulWidget {
  final String? initialGameId; 

  const GachaScreen({Key? key, this.initialGameId}) : super(key: key);

  @override
  _GachaScreenState createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  List<dynamic> gamesList = [];
  List<dynamic> itemsList = [];
  String? selectedGameId;
  Map<String, dynamic>? rolledItem;

  // สถานะเช็คว่าสุ่มไปแล้วแต่ยังไม่ได้กด Confirm
  bool hasPulledWithoutConfirm = false;

  final TextEditingController itemController = TextEditingController();
  final TextEditingController rarityController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // ใช้ URL ของ Vercel ตามที่อยู่ในหน้า HomeScreen
  final String apiUrl = 'https://api-ruddy-one-91.vercel.app';

  @override
  void initState() {
    super.initState();
    selectedGameId = widget.initialGameId;
    fetchGames();
    if (selectedGameId != null) {
      fetchItems(selectedGameId!);
    }
  }

  Future<void> fetchGames() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/games'));
      if (response.statusCode == 200) {
        setState(() {
          gamesList = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  Future<void> fetchItems(String gameId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/games/$gameId/items'));
      if (response.statusCode == 200) {
        setState(() {
          itemsList = json.decode(response.body);
          // เคลียร์ข้อมูลช่องสุ่มเก่าออกเมื่อเปลี่ยนเกม
          rolledItem = null;
          hasPulledWithoutConfirm = false;
          itemController.clear();
          rarityController.clear();
          amountController.clear();
        });
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  // --- ฟังก์ชัน Dialog แจ้งเตือนสุ่มต่อ ---
  Future<bool> showWarningDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('แจ้งเตือน'),
              content: const Text('ต้องการที่จะสุ่มต่อมั้ย? (ผลลัพธ์ก่อนหน้าจะไม่ถูกบันทึก)'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('สุ่มต่อ'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void rollGacha() async {
    if (itemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่มีไอเทมในเกมนี้ให้สุ่ม!')),
      );
      return;
    }

    // ตรวจสอบว่าเคยสุ่มไปแล้วแต่ยังไม่ได้บันทึกหรือไม่
    if (hasPulledWithoutConfirm) {
      bool continueRandom = await showWarningDialog();
      if (!continueRandom) return; 
    }

    final random = Random();
    int randomIndex = random.nextInt(itemsList.length);
    
    setState(() {
      rolledItem = itemsList[randomIndex];
      itemController.text = rolledItem!['itemname'];
      rarityController.text = rolledItem!['itemrarity'];
      amountController.text = "1";
      hasPulledWithoutConfirm = true; // ล็อคสถานะว่ายังไม่ได้ confirm
    });
  }

  Future<void> confirmSave() async {
    if (rolledItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากดสุ่มไอเทมก่อนยืนยัน')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/gacha'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'item_id': rolledItem!['item_id'],
          'amount': int.parse(amountController.text),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลการสุ่มเรียบร้อยแล้ว!'), backgroundColor: Colors.green),
        );
        setState(() {
          hasPulledWithoutConfirm = false; // ปลดล็อคสถานะ
          rolledItem = null;
          itemController.clear();
          rarityController.clear();
          amountController.clear();
        });
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // เอาเงาออกเพื่อให้ดูเป็นแผ่นเดียวกันแบบใน wireframe
        title: const Text('Home'), // ปรับให้เหมือน Wireframe
        actions: [
          // ไอคอน User ให้เหมือนหน้า Home
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // หากมีหน้า Profile สามารถเชื่อม Navigator ตรงนี้ได้เลย
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('game', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            
            // --- Combobox (Dropdown) ขอบเหลี่ยมแบบ Wireframe ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('combobox (show game name)'),
                  value: selectedGameId,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: gamesList.map((game) {
                    return DropdownMenuItem<String>(
                      value: game['game_id'].toString(),
                      child: Text(game['gamename']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGameId = value;
                    });
                    if (value != null) fetchItems(value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- ปุ่ม Random button ขอบเหลี่ยม จัดกึ่งกลาง ---
            Center(
              child: OutlinedButton(
                onPressed: rollGacha,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  side: const BorderSide(color: Colors.black), // ขอบสีดำ
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // ขอบเหลี่ยม
                  foregroundColor: Colors.black,
                ),
                child: const Text('Random button', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 30),
            const Center(child: Text("You've got", style: TextStyle(fontSize: 16))),
            const SizedBox(height: 20),

            // --- TextFields แสดงผลลัพธ์ ---
            _buildReadOnlyTextField('item', itemController),
            const SizedBox(height: 15),
            _buildReadOnlyTextField('rarity', rarityController),
            const SizedBox(height: 15),
            _buildReadOnlyTextField('amount', amountController),
            
            const SizedBox(height: 40),

            // --- ปุ่ม Confirm ขอบเหลี่ยม จัดกึ่งกลาง ---
            Center(
              child: OutlinedButton(
                onPressed: confirmSave,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  side: const BorderSide(color: Colors.black),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  foregroundColor: Colors.black,
                ),
                child: const Text('confirm', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สร้าง TextField ขอบดำแบบใน Wireframe
  Widget _buildReadOnlyTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true, 
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero, // ขอบเหลี่ยม
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            hintText: "text you've got",
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}