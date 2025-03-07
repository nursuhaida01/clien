import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _servicePrefixController =
      TextEditingController();
  final TextEditingController _serviceChannelController =
      TextEditingController();
  bool _isEditing = false;
  int? _editingServiceId;

  Future<void> _saveService() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<QueueProvider>(context, listen: false);
      final newService = ServiceModel(
        id: _editingServiceId,
        name: _serviceNameController.text.trim(),
        prefix: _servicePrefixController.text.trim(),
        deletel: _serviceChannelController.text.trim(),
      );

      try {
        if (_isEditing) {
          await provider.updateService(newService);
          setState(() {}); 
          showAutoCloseDialog(context, "สำเร็จ", "แก้ไขข้อมูลบริการสำเร็จ",
              Icons.check_circle, Colors.green);
        } else {
          await provider.addService(newService);
          showAutoCloseDialog(context, "สำเร็จ", "บันทึกข้อมูลบริการสำเร็จ",
              Icons.check_circle, Colors.green);
        }
       
        _resetForm();
      } catch (e) {
        showAutoCloseDialog(context, "เกิดข้อผิดพลาด", "เกิดข้อผิดพลาด: $e",
            Icons.error, Colors.red);
      }
    }
  }

 Future<void> _deleteService(int? id) async {
  if (id == null) {
    showAutoCloseDialog(
        context, "เกิดข้อผิดพลาด", "ID เป็น null", Icons.error, Colors.red);
    return;
  }

  final provider = Provider.of<QueueProvider>(context, listen: false);

  // ✅ เรียก Dialog ยืนยันก่อนลบ
  bool? confirmDelete = await showConfirmDialog(
    context,
    "ยืนยันการลบ",
    "คุณแน่ใจหรือไม่ว่าต้องการลบบริการนี้?",
    Icons.warning,
    Colors.orange,
  );

  if (confirmDelete == true) {
    try {
      await provider.deleteService(id);
      await provider.fetchServices(); // ✅ โหลดข้อมูลใหม่
      showAutoCloseDialog(context, "สำเร็จ", "ลบข้อมูลบริการสำเร็จ",
          Icons.check_circle, Colors.green);
    } catch (e) {
      showAutoCloseDialog(context, "เกิดข้อผิดพลาด", "เกิดข้อผิดพลาด: $e",
          Icons.error, Colors.red);
    }
  }
}
  // Future<void> _clearAllServices() async {
  //   final provider = Provider.of<QueueProvider>(context, listen: false);

  //   try {
  //     await provider.clearAllServices();
  //     _showSnackBar('ลบข้อมูลบริการทั้งหมดสำเร็จ', Colors.green);
  //   } catch (e) {
  //     _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.red);
  //   }
  // }

  void _editService(ServiceModel service) {
    setState(() {
      _isEditing = true;
      _editingServiceId = service.id;
      _serviceNameController.text = service.name;
      _servicePrefixController.text = service.prefix;
      _serviceChannelController.text = service.deletel;
    });
  }

  void _resetForm() {
    _serviceNameController.clear();
    _servicePrefixController.clear();
    _serviceChannelController.clear();
    setState(() {
      _isEditing = false;
      _editingServiceId = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.05; // 5% ของความสูงหน้าจอ
    final fontSize = size.height * 0.02;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'การจัดการบริการ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.warning,
                          color: Colors.orange, size: fontSize * 1.5),
                      SizedBox(width: size.width * 0.02),
                      Flexible(
                        child: Text('ยืนยันการลบ',
                            style: TextStyle(fontSize: fontSize)),
                      ),
                    ],
                  ),
                  content: Text(
                    'คุณแน่ใจว่าต้องการลบทั้งหมดหรือไม่?\n(ถ้าลบแล้วจะไม่สามารถนำกลับมาได้อีก)',
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.02,
                    horizontal: size.width * 0.0001,
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 0, 0),
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'ปิด|CLOSE',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.01),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromRGBO(9, 159, 175, 1.0),
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'ยืนยัน|SUBMIT',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              if (!confirm) return; // ถ้าผู้ใช้กด "ปิด" ให้ยกเลิกการทำงาน

              final provider =
                  Provider.of<QueueProvider>(context, listen: false);
              await provider.clearAllServices();
              await provider.reloadServices();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(9, 159, 175, 1.0),
              const Color.fromRGBO(9, 159, 175, 1.0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _serviceNameController,
                          maxLength: 15,
                          decoration: InputDecoration(
                            labelText: 'Service Name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่อบริการ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _serviceChannelController,
                          decoration: InputDecoration(
                            labelText: 'detail',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                           inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[1-5]')), // ป้อนเฉพาะตัวเลข 1, 2, 3, 4, 5
                            LengthLimitingTextInputFormatter(1), // จำกัดจำนวนหลักไม่เกิน 5
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกหมายเลขช่องบริการ';
                            }
                            if (int.tryParse(value) == null) {
                              return 'กรุณากรอกตัวเลขเท่านั้น';
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _servicePrefixController,
                          decoration: InputDecoration(
                            labelText: 'Service Prefix',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                2), // จำกัดความยาว 2 ตัวอักษร
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]')), // อนุญาตเฉพาะ a-z, A-Z
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอก prefix';
                            }

                            final provider = Provider.of<QueueProvider>(context,
                                listen: false);
                            final existingPrefixes = provider.services
                                .where((service) =>
                                    service.id !=
                                    _editingServiceId) // ✅ ตรวจสอบเฉพาะ service อื่น
                                .map((service) => service.prefix.toLowerCase())
                                .toList();

                            if (existingPrefixes
                                .contains(value.toLowerCase())) {
                              return 'Prefix นี้ถูกใช้ไปแล้ว กรุณาใช้ prefix อื่น';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveService,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(9, 159, 175, 1.0),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'Update Service' : 'Save Service',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Text(
                'Service List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 254, 254, 254),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Consumer<QueueProvider>(
                  builder: (context, provider, child) {
                    final services = provider.services;

                    if (services.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Services Found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color.fromRGBO(9, 159, 175, 1.0),
                              child: Text(
                                service.prefix,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(service.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Channel: ${service.deletel}| Prefix: ${service.prefix}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => _editService(service),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteService(service.id!),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Future<bool?> showConfirmDialog(BuildContext context, String title,
      String message, IconData icon, Color iconColor) {
    final size = MediaQuery.of(context).size;
    const double fontSize = 18;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // ✅ ป้องกันการแตะข้างนอกเพื่อปิด
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)), // 🔹 ขอบมน
          titlePadding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          contentPadding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.width * 0.05,
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: fontSize * 2), // ✅ ไอคอนใหญ่
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: iconColor),
                textAlign: TextAlign.center, // ✅ จัดให้อยู่ตรงกลาง
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(false), // ❌ กดยกเลิก
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red, // 🔴 ปุ่มสีแดง
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.02),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('ปิด | CLOSE',
                        style: TextStyle(fontSize: fontSize)),
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(true), // ✅ กดยืนยัน
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(
                          9, 159, 175, 1.0), // 🔹 ปุ่มสีฟ้า
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.02),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('ยืนยัน | SUBMIT',
                        style: TextStyle(fontSize: fontSize)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showAutoCloseDialog(BuildContext context, String title, String message,
      IconData icon, Color iconColor) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // ป้องกันการแตะปิดเอง
      builder: (BuildContext dialogContext) {
        // ตั้งเวลาให้ Dialog ปิดเอง
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop(); // ปิด Dialog หลัง 3 วินาที
          }
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
                  Icon(icon, color: iconColor, size: 70), // ไอคอนแบบกำหนดเอง
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
