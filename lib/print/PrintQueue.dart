import 'package:flutter/material.dart';
import '../model/queue_model.dart';

class QueueHelper {
  static Future<void> printQueueTicket(
      BuildContext context, QueueModel queue) async {
    try {
      final ticket = '''
      --------------------------
      Queue Ticket
      --------------------------
      Queue Number: ${queue.queueNumber}
      Customer Name: ${queue.customerName}
      Phone: ${queue.customerPhone}
      Status: ${queue.queueStatus}
      Time: ${queue.queueDatetime}
      --------------------------
      ''';

      // จำลองการพิมพ์ (หรือเชื่อมต่อเครื่องพิมพ์จริง)
      print(ticket);

      // ตัวอย่าง: ใช้ esc_pos_printer หรือเครื่องพิมพ์อื่นๆ
      // final printer = NetworkPrinter(PaperSize.mm80, CapabilityProfile.load());
      // await printer.connect('192.168.0.123', port: 9100);
      // printer.text(ticket);
      // printer.disconnect();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('พิมพ์บัตรคิวสำเร็จ')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถพิมพ์บัตรคิวได้: $e')),
      );
    }
  }
}
