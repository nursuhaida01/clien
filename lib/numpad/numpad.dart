import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../coding/dialog.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';
import '../providers/queue_provider.dart';

class Numpad extends StatefulWidget {
  final Function(String, String, String) onSubmit;
  final Map<String, dynamic> T1;
  final int? serviceIds;

  Numpad({required this.onSubmit, required this.T1, required this.serviceIds});

  @override
  _NumpadState createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paxController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  PageController _pageController = PageController();
  bool _isLoading = false;
  bool isChecked = false;
  late QueueProvider _dataProvider;

  get selectedServiceId => Null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = Provider.of<QueueProvider>(context);
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final hiveData = Provider.of<QueueProvider>(context);
    String? storedValue = hiveData.givenameValue ?? "Loading...";
    if (storedValue == 'Checked') {
      setState(() {
        isChecked = true;
      });
    }
  }
  Future<void> _saveQueue() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final queue = QueueModel(
        queueNumber: int.parse(_paxController.text.trim()),
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        queueStatus: 'รอรับบริการ',
        queueDatetime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        queueCreate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        serviceId: widget.serviceIds ?? 0,
      );

      try {
        await DatabaseHelper.instance.insertQueue(queue);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showAlertDialog(context, 'กรุณากรอกข้อมูลให้ครบ');
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.02;
    final buttonHeight = size.height * 0.05;

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : PageView(
            controller: _pageController,
            children: [
              // หน้าแรก: กรอกจำนวนลูกค้า (Pax)
              Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'จำนวนลูกค้า | Pax Qty',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize * 2.0),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        buildNumpad(_controller), // แสดง Numpad
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.of(context).pop(); // ปิด Numpad
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.6),
                            ),
                            child: Text(
                              'ปิด | CANCEL',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ),
                         const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _showAlertDialog(
                                    context, 'กรุณาป้อนจำนวนลูกค้า');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromRGBO(9, 159, 175, 1.0),
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.6), // ปรับขนาดปุ่ม
                            ),
                            child: Text(
                              isChecked ? 'ต่อไป | NEXT' : 'ยืนยัน | SUBMIT',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // หน้าที่สอง: กรอกชื่อและเบอร์โทร
              Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TextField สำหรับกรอกชื่อ
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            controller: _customerNameController,
                            decoration: InputDecoration(
                              hintText: 'ชื่อ | Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize * 1.3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // TextField สำหรับกรอกเบอร์โทร
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _customerPhoneController,
                            decoration: InputDecoration(
                              hintText: 'เบอร์ | Phone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize * 1.3),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  13), // จำกัดตัวอักษรสูงสุด 13 ตัว
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        // ปุ่มกลับ | BACK
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.6),
                            ),
                            child: Text('กลับ | BACK',
                                style: TextStyle(fontSize: fontSize)),
                          ),
                        ),
                        const SizedBox(width: 10), // ระยะห่างระหว่างปุ่ม
                        // ปุ่มยืนยัน | SUBMIT
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final customerName = _customerNameController.text;
                              final customerPhone =
                                  _customerPhoneController.text;
                              final paxText = _controller.text;

                              if (customerName.isNotEmpty &&
                                  customerPhone.isNotEmpty &&
                                  paxText.isNotEmpty) {
                                try {
                                  final queueNumber = int.parse(
                                      paxText); // แปลง String เป็น int
                                  var serviceId;
                                  final queue = QueueModel(
                                    queueNumber: queueNumber,
                                    customerName: customerName,
                                    customerPhone: customerPhone,
                                    queueStatus: 'รอรับบริการ',
                                    queueDatetime:
                                        DateFormat('yyyy-MM-dd HH:mm:ss')
                                            .format(DateTime.now()),
                                    queueCreate:
                                        DateFormat('yyyy-MM-dd HH:mm:ss')
                                            .format(DateTime.now()),
                                    serviceId: widget.serviceIds ?? 0,
                                  );

                                  // เรียกใช้งาน DatabaseHelper
                                  await DatabaseHelper.instance
                                      .insertQueue(queue);

                                  // แสดงข้อความสำเร็จ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('บันทึกข้อมูลสำเร็จ')),
                                  );

                                         


                                  Navigator.of(context)
                                      .pop(); // ปิด Dialog หรือ Numpad
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('เกิดข้อผิดพลาด: $e')),
                                  );
                                }
                              } else {
                                _showAlertDialog(
                                    context, 'กรุณากรอกข้อมูลให้ครบ');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromRGBO(9, 159, 175, 1.0),
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.6),
                            ),
                            child: Text('ยืนยัน | SUBMIT',
                                style: TextStyle(fontSize: fontSize)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget buildNumpad(TextEditingController controller) {
  final List<String> numpadButtons = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '',
    '0',
    'delete'
  ];
  final size = MediaQuery.of(context).size;
  final fontSize = size.height * 0.03;

  return Expanded(
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: (size.width * 0.3).clamp(50.0, 170.0),
        mainAxisSpacing: 4,
        crossAxisSpacing: 30,
        childAspectRatio: 1,
      ),
      itemCount: numpadButtons.length,
      itemBuilder: (context, index) {
        final buttonText = numpadButtons[index];

        return ElevatedButton(
          onPressed: () {
            if (buttonText == 'delete') {
              // ลบข้อความตัวสุดท้าย
              if (controller.text.isNotEmpty) {
                controller.text =
                    controller.text.substring(0, controller.text.length - 1);
              }
            } else if (buttonText == '0') {
              // ป้องกันไม่ให้กด 0 เป็นตัวแรก
              if (controller.text.isNotEmpty) {
                controller.text += buttonText;
              }
            } else if (buttonText.isNotEmpty) {
              // เพิ่มตัวเลขอื่น ๆ
              controller.text += buttonText;
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonText == 'delete'
                ? Colors.red
                : const Color.fromRGBO(9, 159, 175, 1.0),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Center(
            child: Text(
              buttonText == 'delete' ? 'ลบ' : buttonText,
              style: TextStyle(fontSize: fontSize * 2.0, color: Colors.white),
            ),
          ),
        );
      },
    ),
  );
}

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }
}
