import 'package:flutter/material.dart';

class DialogHelper {
  // แสดง Dialog แบบยืนยัน
  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
                onConfirm(); // เรียกฟังก์ชันที่ส่งมา
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // แสดง Dialog แบบแสดงข้อความทั่วไป
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // แสดง Custom Dialog พร้อม Widget ที่กำหนดเอง
  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content, required IconData icon, required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // แสดง SnackBar แบบกำหนดเอง
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.blue,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
