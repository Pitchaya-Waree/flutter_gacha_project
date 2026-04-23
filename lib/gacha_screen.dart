import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class GachaScreen extends StatefulWidget {
  final String? initialGameId; // รับค่า game_id จากหน้า Home (ถ้ามี)

  const GachaScreen({Key? key, this.initialGameId}) : super(key: key);

  @override
  _GachaScreenState createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  // ตัวแปรเก็บข้อมูล
  List<dynamic> gamesList = [];
  List<dynamic> itemsList = [];
  String? selectedGameId;
  Map<String, dynamic>? rolledItem;

  // Controllers สำหรับ TextFields
  final TextEditingController itemController = TextEditingController();
  final TextEditingController rarityController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // URL ของ API (เปลี่ยนเป็นของ Vercel ของคุณ)
  final String apiUrl = 'https://your-vercel-api-url.vercel.app/';

  @override
  void initState() {
    super.initState();
    selectedGameId = widget.initialGameId;
    fetchGames();
    if (selectedGameId != null) {
      fetchItems(selectedGameId!);
    }
  }

  // 1. โหลดรายชื่อเกมใส่ Combobox
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

  // 2. โหลดไอเทมของเกมที่เลือก
  Future<void> fetchItems(String gameId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/games/$gameId/items'));
      if (response.statusCode == 200) {
        setState(() {
          itemsList = json.decode(response.body);
          // เคลียร์ช่องสุ่มเก่าออกเมื่อเปลี่ยนเกม
          rolledItem = null;
          itemController.clear();
          rarityController.clear();
          amountController.clear();
        });
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  // 3. ฟังก์ชันสุ่มไอเทม
  void rollGacha() {
    if (itemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่มีไอเทมในเกมนี้ให้สุ่ม!')),
      );
      return;
    }

    final random = Random();
    int randomIndex = random.nextInt(itemsList.length);
    
    setState(() {
      rolledItem = itemsList[randomIndex];
      itemController.text = rolledItem!['itemname'];
      rarityController.text = rolledItem!['itemrarity'];
      amountController.text = "1"; // กำหนดจำนวนที่ได้เป็น 1 ชิ้น
    });
  }

  // 4. ฟังก์ชันยืนยันและบันทึกลง Database
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลการสุ่มเรียบร้อยแล้ว!'), backgroundColor: Colors.green),
        );
        // เคลียร์ข้อมูลหลังบันทึกเสร็จ (หรือจะให้เด้งกลับหน้าโฮมก็ได้)
        setState(() {
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
      appBar: AppBar(
        title: const Text('Gacha'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(child: Text('User', style: TextStyle(fontSize: 12))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Game', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // --- Combobox (Dropdown) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('เลือกเกมที่จะสุ่ม'),
                  value: selectedGameId,
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
            const SizedBox(height: 20),

            // --- ปุ่ม Random ---
            ElevatedButton(
              onPressed: rollGacha,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Random button', style: TextStyle(fontSize: 16)),
            ),
            
            const SizedBox(height: 30),
            const Center(child: Text("You've got", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),

            // --- TextFields แสดงผลลัพธ์ ---
            _buildReadOnlyTextField('Item', itemController),
            const SizedBox(height: 15),
            _buildReadOnlyTextField('Rarity', rarityController),
            const SizedBox(height: 15),
            _buildReadOnlyTextField('Amount', amountController),
            
            const SizedBox(height: 40),

            // --- ปุ่ม Confirm ---
            ElevatedButton(
              onPressed: confirmSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Confirm', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สร้าง TextField แบบอ่านอย่างเดียว (ReadOnly) ให้ออกมาเหมือนใน Wireframe
  Widget _buildReadOnlyTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true, // ทำให้พิมพ์แก้ไขไม่ได้
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            hintText: "text you've got",
            filled: true,
            fillColor: Colors.black12, // สีพื้นหลังจางๆ แสดงว่าเป็นช่องที่พิมพ์ไม่ได้
          ),
        ),
      ],
    );
  }
}