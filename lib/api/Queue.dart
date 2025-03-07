import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../coding/dialog.dart';
import '../database/db_helper.dart';
import '../model/queue.dart';

class ClassCRUD {
  // ฟังก์ชัน UpdateQueue สำหรับ "หลายคิว" (List ของ Map)
  Future<void> UpdateQueue({
    required BuildContext context,
    required List<Map<String, dynamic>> SearchQueue, // <- รายการคิวที่ต้องอัปเดต
    required String StatusQueueNote,
    required String queueStatus, 
     
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // สมมติว่าอยากบันทึกวัน/เวลาอัปเดตตอนนี้ (ถ้าอยากเก็บ)
      final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      int totalUpdated = 0;

      // วนลูปทีละคิวใน SearchQueue
      for (var queue in SearchQueue) {
        // ดึง ID ของคิวแต่ละตัว (กรณีฟิลด์ชื่อ 'id')
        final queueId = queue['queue_no'];
        if (queueId == null) {
          // ถ้าไม่มี id ข้ามไป
          continue;
        }

        // อัปเดตข้อมูลในตาราง queue_tb
        final rowsAffected = await db.update(
          'queue_tb',
          {
           
            'queue_datetime': now,   
            'queue_status':"รับบริการ" // วัน/เวลาอัปเดต
           
          },
          where: 'queue_no = ?', 
          whereArgs: [queueId],
        );

        // เช็กว่ามีแถวที่ถูกอัปเดตหรือไม่
        if (rowsAffected > 0) {
          totalUpdated++;
        }
      }
       String ToMsg = "";
      ToMsg = "กำลังจบคิว\nEnd Queue"; 
        String queueNumber =
            " ";
    
         await DialogHelper.showCustomDialog(
            context, ToMsg, queueNumber,   Icons.surround_sound);


     
    } catch (error) {
      // หากเกิดข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    }
  }

  static updateQueue({required BuildContext context, required queueId, required String newStatus, required Future<void> Function(int queueId, String newStatus) updateStatusFunction}) {}
}
