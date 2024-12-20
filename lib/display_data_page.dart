import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';

class DisplayDataPage extends StatelessWidget {
  const DisplayDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แสดงข้อมูลคิว'),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: FutureBuilder<List<QueueModel>>(
        future: DatabaseHelper.instance.queryAll('queue_tb'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลในระบบ'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final queue = data[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text('ชื่อ: ${queue.customerName}\nคิวที่: ${queue.id}\nservice: ${queue.serviceId}'),
                  subtitle: Text(
                    'เบอร์: ${queue.customerPhone}\nจำนวนคน: ${queue.queueNumber}\nสถานะ: ${queue.queueStatus}\nวันที่เวลา: ${queue.queueDatetime}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteQueue(queue.id!);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const DisplayDataPage()));
                    },
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
