import 'package:flutter/material.dart';
import '../model/service_model.dart';
import '../providers/queue_provider.dart';
import 'package:provider/provider.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceChannelController = TextEditingController();

  Future<void> _saveService() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<QueueProvider>(context, listen: false);
      final newService = ServiceModel(
        name: _serviceNameController.text.trim(),
        deletel: _serviceChannelController.text.trim(),
      );

      try {
        await provider.addService(newService);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลบริการสำเร็จ')),
        );
        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service'),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ชื่อบริการ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(
                  hintText: 'กรอกชื่อบริการ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อบริการ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'หมายเลขช่องบริการ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _serviceChannelController,
                decoration: const InputDecoration(
                  hintText: 'กรอกหมายเลขช่องบริการ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกหมายเลขช่องบริการ';
                  }
                  if (int.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขเท่านั้น';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveService,
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
      ),
    );
  }
}
