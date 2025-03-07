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
  required IconData icon,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) { // ใช้ dialogContext
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: const Color.fromARGB(255, 255, 0, 0), size: 70),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // ปิด Dialog หลังจากหน่วงเวลา 3 วินาที
  await Future.delayed(const Duration(seconds: 3));
  Navigator.of(context).pop(); // ใช้ context ที่ถูกต้อง
}

// แสดง Custom Dialog พร้อม Widget ที่กำหนดเอง
  static Future<void> showCustomDialog(
      BuildContext context, String toMsg, String queueNumber, IconData icon) {
    // Show the dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(icon,
                      color: const Color.fromARGB(255, 255, 0, 0), size: 70),
                  Text(
                    toMsg,
                    style: const TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    queueNumber,
                    style: const TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Wait for 3 seconds before dismissing the dialog
    return Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the dialog
    });
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
