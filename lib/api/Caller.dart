import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../coding/dialog.dart';
import '../database/db_helper.dart';

Future<void> CallQueue({
  required BuildContext context,
  required List<Map<String, dynamic>> SearchQueue,
}) async {
  try {
     final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // วนลูปเรียกคิวจาก SearchQueue
    for (var queue in SearchQueue) {
      final queueNo = queue['queue_no'] ?? "ไม่มีข้อมูลคิว"; // ดึงหมายเลขคิว
      final queueId = queue['id'] ?? 0; // ดึง ID คิว (ควรเป็นตัวเลข)

      // แสดงข้อความเฉพาะหมายเลขคิวที่กำลังเรียก
      String message = "กำลังเรียกคิว หมายเลขคิว: $queueNo";

      await DialogHelper.showInfoDialog(
        context: context,
        title: "กำลังเรียกคิว",
        message: message, // ใช้ message สำหรับแสดงข้อมูล
        icon: Icons.queue, // ใส่ไอคอนที่เหมาะสม
      );

      // อัปเดตสถานะคิวเป็น 'กำลังเรียกคิว' ใน SQLite
      await DatabaseHelper.instance.updateQueueStatus(
        queueId,
        'กำลังเรียกคิว',
         now
      );
    }
  } catch (e) {
    // หากเกิดข้อผิดพลาดให้แสดงข้อความ
    await DialogHelper.showInfoDialog(
      context: context,
      title: "ข้อผิดพลาด",
      message: "เกิดข้อผิดพลาด: $e",
      icon: Icons.error, // ไอคอนสำหรับข้อผิดพลาด
    );
  }
}
