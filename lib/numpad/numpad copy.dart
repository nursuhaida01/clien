import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../coding/dialog.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';

import '../print/print_true.dart';
import '../print/testprint.dart';
import '../providers/dataProvider.dart';
import '../providers/queue_provider.dart';

class Numpad extends StatefulWidget {
  final Function(String, String, String) onSubmit;
  final Map<String, dynamic> T1;
  final int? serviceIds;
  late DataProvider _dataProvider;
   final List<Map<String, String>> savedData; // ✅ ประกาศตัวแปร savedData


  Numpad({required this.onSubmit, required this.T1, required this.serviceIds, required this.savedData});

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
  List<Map<String, String>> savedData = [];

  PageController _pageController = PageController();
  bool _isLoading = false;
  bool isChecked = false;
  late QueueProvider _dataProvider;
  late DataProvider _Provider;
  PrintNewAP printnewap = PrintNewAP();

  get selectedServiceId => Null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = Provider.of<QueueProvider>(context);
    _Provider = Provider.of<DataProvider>(context);
    initPlatformState();
    loadFromHive();
  }

  void loadFromHive() async {
    var box = Hive.box('savedDataBox');
    List<Map<String, String>>? loadedData = List<Map<String, String>>.from(
      box.get('savedData', defaultValue: []),
    );

    setState(() {
      savedData = loadedData;
    });
  }

// บันทึกข้อมูลใหม่ลงใน savedDataBox
  void saveToHive() async {
    var box = Hive.box('savedDataBox');
    await box.put('savedData', savedData);
  }

  Future<void> initPlatformState() async {
    final hiveData = Provider.of<DataProvider>(context);
    String? storedValue = hiveData.givenameValue ?? "Loading...";
    if (storedValue == 'Checked') {
      setState(() {
        isChecked = true;
      });
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
                              'ต่อไป | NEXT', // ✅ แสดง "ต่อไป | NEXT" ตลอดเวลา
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
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            controller: _customerPhoneController,
                            decoration: InputDecoration(
                              hintText: 'เบอร์ | Phone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize * 1.3),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  10), // จำกัดตัวอักษรสูงสุด 10 ตัว
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
                            child: Text(
                              'กลับ | BACK',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // ระยะห่างระหว่างปุ่ม
                        // ปุ่มยืนยัน | SUBMIT
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              final customerName = _customerNameController.text;
                              final customerPhone =
                                  _customerPhoneController.text;
                              final paxText = _controller.text;

                              if (paxText.isNotEmpty) {
                                try {
                                  final queueNumber = int.parse(
                                      paxText); // แปลง String เป็น int
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
                                    serviceId: (widget.serviceIds ?? 0).toInt(),
                                    queueNo: '',
                                  );
                                  // ✅ ตรวจสอบการเชื่อมต่อของเครื่องพิมพ์ก่อนทำการพิมพ์
                                  // bool? isPrinterConnected =
                                  //     await printnewap.bluetooth.isConnected;
                                  // if (isPrinterConnected != true) {
                                  //   await DialogHelper.showInfoDialog(
                                  //     context: context,
                                  //     title: "แจ้งเตือน",
                                  //     message:
                                  //         "กรุณาเชื่อมต่อเครื่องพิมพ์ก่อนดำเนินการ",
                                  //     icon: Icons
                                  //         .print_disabled, // ใช้ไอคอนแจ้งเตือน
                                  //   );
                                  //   setState(() {
                                  //     _isLoading = false;
                                  //   });
                                  //   return; // หยุดการทำงานที่นี่ถ้าเครื่องพิมพ์ยังไม่ได้เชื่อมต่อ
                                  // }

                                  // เพิ่มข้อมูลในฐานข้อมูล
                                  final insertedId = await DatabaseHelper
                                      .instance
                                      .insertQueue(queue);

                                  // ดึงข้อมูล QueueModel ที่มี queue_no
                                  final updatedQueue = await DatabaseHelper
                                      .instance
                                      .getQueueById(insertedId);

                                  // เรียกฟังก์ชันพิมพ์
                                  await printnewap.sample(
                                      context, updatedQueue,widget.savedData);

                                  String queueMessage =
                                      "กำลังพิมพ์บัตรคิว\nPrint Ticket";
                                  await DialogHelper.showInfoDialog(
                                    context: context,
                                    title: queueMessage,
                                    message: "",
                                    icon: Icons.warning,
                                  );
                                  // โหลดข้อมูลใหม่

                                  Navigator.of(context)
                                      .pop(); // ปิด Dialog หรือ Numpad
                                  final provider = Provider.of<QueueProvider>(
                                      context,
                                      listen: false);
                                  await provider
                                      .reloadServices(); // เรียกฟังก์ชัน reloadServices
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('เกิดข้อผิดพลาด: $e')),
                                  );
                                }
                              } else {
                                _showAlertDialog(context,
                                    'กรุณากรอกจำนวนลูกค้า'); // แจ้งเตือนหาก Pax ว่างเปล่า
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromRGBO(9, 159, 175, 1.0),
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.6),
                            ),
                            child: Text(
                              'ยืนยัน | SUBMIT',
                              style: TextStyle(fontSize: fontSize),
                            ),
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

  void _showAlertDialog(BuildContext context, String message,
      {IconData? customIcon, Color? iconColor}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  customIcon ?? Icons.info,
                  color: iconColor ?? Colors.blue,
                  size: 60,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
