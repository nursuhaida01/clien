import 'package:flutter/material.dart';

class SettingsPopup extends StatelessWidget {
  const SettingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('การตั้งค่า'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 100, // ความกว้างสูงสุด 80%
          maxHeight: MediaQuery.of(context).size.height * 50, // ความสูงสูงสุด 60%
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('คุณสามารถปรับการตั้งค่าต่าง ๆ ได้ที่นี่'),
            
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // ปิด Popup
          },
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () {
            // เพิ่มฟังก์ชันที่ต้องการ เช่น บันทึกการตั้งค่า
            Navigator.of(context).pop(); // ปิด Popup
          },
          child: const Text('ตกลง'),
        ),
      ],
    );
  }
}
