import 'package:client/model/queue_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../client.dart';
import '../coding/dialog.dart';
import '../database/db_helper.dart';

class ClassCaller {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late ClientModel clientModel;
  ClassCaller() {
    clientModel = ClientModel(
      hostname: '192.168.0.104',
      port: 9000,
      onData: (data) {
        debugPrint('✅ Data received: ${String.fromCharCodes(data)}');
      },
      onError: (error) {
        debugPrint('❌ Error: $error');
      },
      onStatusChange: (status) {
        debugPrint('🔄 Status: $status');
      },
    );

    debugPrint("🔗 ClientModel Initialized");
  }

  Future<void> CallQueue({
    required BuildContext context,
    required String searchStatus,
    required int queueId,   
    required int serviceId,
      
  }) async {
    try {
       // ⏳ กำหนดเวลาปัจจุบัน
    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // ดึงข้อมูลคิวทั้งหมดจากฐานข้อมูล
     final queue = await dbHelper.getQueueByIdAndService(queueId, serviceId);
     // ตรวจสอบว่ามีคิวที่มีสถานะ "กำลังเรียกคิว" อยู่ก่อนหรือไม่
      if (queue == null) {
        debugPrint("❌ ไม่พบคิวที่ต้องการอัปเดต (queueId: $queueId, serviceId: $serviceId)");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ไม่พบคิวที่ต้องการอัปเดต')),
        );
        return;
      }

      debugPrint(" พบ Queue: ID: ${queue.id}, No: ${queue.queueNo}, Status: ${queue.queueStatus}");

      //  ตรวจสอบว่ามีคิวที่ "กำลังเรียกคิว" ใน Service นี้หรือไม่
      final existingCallingQueue = await dbHelper.getCallingQueueByService(serviceId);

      if (existingCallingQueue != null) {
        debugPrint("⚠️ มีคิวกำลังเรียกอยู่ใน Service ID: $serviceId");
        await DialogHelper.showCustomDialog(
          context,
          "",
          "⚠️ กรุณาเคลียคิวให้เสร็จสิ้นก่อน",
          Icons.surround_sound,
        );
        return;
      }

      // กรองข้อมูลตาม searchStatus
    
      // ตรวจสอบว่ามีข้อมูลที่ตรงกับเงื่อนไขหรือไม่
    

      // ประมวลผลข้อมูลที่ผ่านการกรอง
   
       if (queue.queueStatus == 'รอรับบริการ') {
        await dbHelper.updateQueueStatus(queueId, 'กำลังเรียกคิว', now);
        debugPrint("✅ อัปเดตคิวสำเร็จ: Queue ID: ${queue.id}, No: ${queue.queueNo}");

        // ✅ แสดง Dialog แจ้งเตือน
        await DialogHelper.showCustomDialog(
          context,
          "",
          " กำลังเรียกคิว หมายเลข: ${queue.queueNo}",
          Icons.surround_sound,
        );
         
      } else {
        debugPrint("⚠️ คิวไม่อยู่ในสถานะที่สามารถอัปเดตได้");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ คิวไม่สามารถอัปเดตได้')),
        );
      }
    } catch (error) {
      debugPrint(" Error updating queue: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' เกิดข้อผิดพลาด: $error')),
      );
    }
  }
}

// การใช้งานใน Widget
class QueuePage extends StatelessWidget {
  final ClassCaller classCaller = ClassCaller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Management')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
             final queue = await DatabaseHelper.instance.getFirstQueueByStatus("พักคิว");

            // เรียกฟังก์ชัน CallQueue โดยกรองสถานะ "รอรับบริการ"
            if (queue != null) {
            await classCaller.CallQueue(
              context: context,
              searchStatus: 'รอรับบริการ',
               queueId: queue.id!,  // ✅ ใช้ queueId อัตโนมัติ
              serviceId: queue.serviceId!, // ✅ ใช้ serviceId อัตโนมัติ
            );
             } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ ไม่พบคิวในสถานะ "รอรับบริการ"')),
              );
            }
          },
          child: const Text('เรียกคิว'),
        ),
      ),
    );
  }
}
