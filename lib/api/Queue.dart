import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ClassCRUD {
  // ฟังก์ชัน UpdateQueue
  Future<void> UpdateQueue({
    required BuildContext context,
    required int queueId, // ID ของคิวที่ต้องการอัปเดต
    required String queueStatus, // สถานะใหม่ของคิว
    required String queueDatetime, // วันที่/เวลาของสถานะ
  }) async {
    try {
      // เรียกฐานข้อมูล SQLite
      final db = await DatabaseHelper.instance.database;

      // อัปเดตข้อมูลในตาราง queue_tb
      int rowsAffected = await db.update(
        'queue_tb', // ชื่อตาราง
        {
          'queue_status': queueStatus, // อัปเดตสถานะคิว
          'queue_datetime': queueDatetime, // อัปเดตวันที่/เวลา
        },
        where: 'id = ?', // เงื่อนไขการอัปเดต (ระบุ ID ของคิว)
        whereArgs: [queueId], // ค่าของเงื่อนไข (queueId)
      );

      if (rowsAffected > 0) {
        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตสถานะคิวสำเร็จ')),
        );
      } else {
        // หากไม่มีข้อมูลถูกอัปเดต
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบคิวที่ต้องการอัปเดต')),
        );
      }
    } catch (error) {
      // จัดการข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    }
  }
}
