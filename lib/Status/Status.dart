import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/status_model.dart';

class AddStatusPage extends StatefulWidget {
  @override
  _AddStatusPageState createState() => _AddStatusPageState();
}

class _AddStatusPageState extends State<AddStatusPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _statusNameController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> _saveStatus() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newStatus = StatusModel(statusName: _statusNameController.text);

      try {
        await dbHelper.insertStatus(newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกสถานะสำเร็จ')),
        );
        _statusNameController.clear(); // เคลียร์ช่องกรอกข้อมูล
        setState(() {}); // รีเฟรชหน้าจอเพื่อโหลดข้อมูลใหม่
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<List<StatusModel>> _fetchStatuses() async {
    return await dbHelper.queryAllStatuss(); // ฟังก์ชันดึงข้อมูลสถานะทั้งหมดจากฐานข้อมูล
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มสถานะใหม่'),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ชื่อสถานะ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _statusNameController,
                    decoration: const InputDecoration(
                      hintText: 'กรุณากรอกชื่อสถานะ',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกชื่อสถานะ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'บันทึกข้อมูล',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'รายการสถานะที่มีอยู่',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<StatusModel>>(
                future: _fetchStatuses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('ไม่มีข้อมูลสถานะ'),
                    );
                  }

                  final statuses = snapshot.data!;
                  return ListView.builder(
                    itemCount: statuses.length,
                    itemBuilder: (context, index) {
                      final status = statuses[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
                            child: Text(
                              '${status.statusId}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text('ชื่อสถานะ: ${status.statusName}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
