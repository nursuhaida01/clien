import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';
import '../providers/queue_provider.dart';

class QueueDisplayPage extends StatefulWidget {
  const QueueDisplayPage({Key? key}) : super(key: key);

  @override
  _QueueDisplayPageState createState() => _QueueDisplayPageState();
}

class _QueueDisplayPageState extends State<QueueDisplayPage> {
  bool _isLoading = false;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

//   Future<void> _deleteQueue(int queueId) async {
//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     await dbHelper.deleteQueue(queueId);
//     final provider = Provider.of<QueueProvider>(context, listen: false);
//     await provider.reloadServices(); // ✅ โหลดข้อมูลใหม่

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('ลบคิวเรียบร้อยแล้ว')),
//     );

//     Navigator.pop(context); // ✅ ปิดหน้า QueueDisplayPage หลังลบสำเร็จ
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
//     );
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }
Future<void> _deleteQueue(int queueId) async {
  setState(() {
    _isLoading = true; // เปิดสถานะกำลังโหลด
  });

  try {
    // ✅ ดึง Provider เพื่อจัดการข้อมูล
    final provider = Provider.of<QueueProvider>(context, listen: false);

    // ✅ เคลียร์ข้อมูลในหน้าแสดงคิวก่อน
    provider.clearQueues(); // ล้างข้อมูลใน Provider (หน้าก่อนหน้า)

    // ✅ ลบคิวในฐานข้อมูล
    await dbHelper.deleteQueue(queueId);

    // ✅ โหลดข้อมูลใหม่หลังจากลบเสร็จ
    await provider.reloadServices();

    // ✅ แสดงข้อความแจ้งเตือน
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ลบคิวเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // ✅ กลับไปหน้าก่อนหน้า
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เกิดข้อผิดพลาด: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoading = false; // ปิดสถานะกำลังโหลด
    });
  }
}

  Future<List<QueueModel>> _fetchQueues() async {
    return await dbHelper.queryAllQueues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการคิวทั้งหมด'),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<QueueModel>>(
              future: _fetchQueues(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('ไม่มีข้อมูลคิว'));
                }

                final queues = snapshot.data!;
                return ListView.builder(
                  itemCount: queues.length,
                  itemBuilder: (context, index) {
                    final queue = queues[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Queue No: ${queue.queueNo}'),
                        subtitle: Text('Customer: ${queue.customerName}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteQueue(queue.id!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
