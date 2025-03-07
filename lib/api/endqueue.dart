import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart'; // นำเข้า DatabaseHelper
import '../model/queue_model.dart'; // นำเข้า QueueModel

class QueueHandler {
  Future<void> _endQueue(BuildContext context, QueueModel queue) async {
     // ⏳ กำหนดเวลาปัจจุบัน
    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // ตรวจสอบและแปลง queueNo เป็น int
    final queueId = int.tryParse(queue.queueNo);

    if (queueId != null) {
      try {
        // เรียกฟังก์ชันอัปเดตสถานะในฐานข้อมูล
        await DatabaseHelper.instance.updateQueueStatus(queueId, "จบคิว", now);
        debugPrint("Queue $queueId has been updated to 'จบคิว'");

        // แสดง Dialog ว่าอัปเดตสถานะสำเร็จ
        _showReasonDialog(
          context,
          'End Queue', // ชื่อ Dialog
          'Queue ${queue.queueNo} has been ended successfully.', // แสดงหมายเลขคิวที่จบ
          Icons.check_circle, // ไอคอนที่ใช้
        );
      } catch (e) {
        debugPrint("Error updating queue: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating queue: $e')),
        );
      }
    } else {
      debugPrint("Invalid Queue ID: ${queue.queueNo}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Queue ID')),
      );
    }
  }

  Future<void> _showReasonDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด Dialog โดยการแตะนอก Dialog
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(dialogContext).pop(); // ปิด Dialog หลัง 3 วินาที
        });
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
                  Icon(icon, color: Colors.green, size: 70),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
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
  }
}
