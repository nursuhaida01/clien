import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../print/testprint.dart';
import '../providers/dataProvider.dart';
import 'dart:ui' as ui;

import '../providers/queue_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();

  static void sample(BuildContext context, Map<String, dynamic> qrData) {}
}

class _SettingScreenState extends State<SettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  TestPrint testPrint = TestPrint();

  bool isChecked = false;
  bool isChecked58 = false;
  bool isChecked80 = false;
  late DataProvider _dataProvider;
  late QueueProvider _QueueProvider;
  // ฟอร์มกรอกข้อมูลร้าน
  final _formKey = GlobalKey<FormState>();
  // ใช้ TextEditingController เพื่อควบคุมค่า TextFormField
  final TextEditingController line1Controller = TextEditingController();
  final TextEditingController line2Controller = TextEditingController();
  final TextEditingController line3Controller = TextEditingController();

  String? line1;
  String? line2;
  String? line3;

  // List สำหรับเก็บข้อมูลร้าน

  List<Map<String, String>> savedData = [];

  bool _isEditing = false;
  int? editIndex; // ใช้เก็บ index เมื่อแก้ไข
// QueueProvider
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = Provider.of<DataProvider>(context);
    _QueueProvider = Provider.of<QueueProvider>(context);
    initPlatformState();
    loadFromHive();
    // _loadCheckboxState();
    initPlatformState1();
  }
Future<void> loadFontFromAsset() async {
  final fontData = await rootBundle.load('assets/fonts/THSarabunNew.ttf');
  final fontLoader = FontLoader('THSarabunNew');
  fontLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
  await fontLoader.load();
}

  // แปลงเป็นรูป
 Future<void> generateImageFromSavedData(List<Map<String, String>> savedData) async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final Map<String, double> fontSizeMap = {
    'line1': 60,
    'line2': 40,
    'line3': 40,
  };

  for (int index = 0; index < savedData.length; index++) {
    final item = savedData[index];

    for (var key in ['line1', 'line2', 'line3']) {
      final text = item[key]?.trim() ?? ''; // ✅ ถ้าว่างให้เป็นค่าว่าง
      final double fontSize = fontSizeMap[key] ?? 40;

      // ✅ เช็คว่าข้อความเป็นค่าว่างไหม ถ้าว่างให้ข้ามไป
      if (text.isEmpty) {
        final filePath = '${appDocDir.path}/savedData_${key}_${index + 1}.png';
        final file = File(filePath);
        await file.writeAsBytes([]); // ✅ บันทึกเป็นไฟล์ว่าง
        print("✅ ไฟล์ว่างถูกสร้างที่: $filePath");
        continue;
      }

      // ✅ เรนเดอร์ข้อความลง Canvas
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: 'THSarabunNew',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      final textWidth = textPainter.width + 20;
      final textHeight = textPainter.height + 20;

      // ✅ วาดพื้นหลังและข้อความ
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, textWidth, textHeight));
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, textWidth, textHeight), Paint()..color = Colors.white);
      textPainter.paint(canvas, Offset(10, 10));

      // ✅ แปลงเป็นไฟล์ PNG
      final picture = recorder.endRecording();
      final img = await picture.toImage(textWidth.toInt(), textHeight.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // ✅ เขียนทับไฟล์เดิม
      final filePath = '${appDocDir.path}/savedData_${key}_${index + 1}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      print("✅ ไฟล์ถูกสร้างและบันทึกที่: $filePath");
    }
  }
}

  Future<void> addToHive58(String GiveName) async {
    Provider.of<QueueProvider>(context, listen: false)
        .setGiveName58Value(GiveName);
    setState(() {});
  }

  Future<void> addToHive80(String GiveName) async {
    Provider.of<QueueProvider>(context, listen: false)
        .setGiveName80Value(GiveName);
    setState(() {});
  }

  Future<void> initPlatformState1() async {
    final hiveData = Provider.of<QueueProvider>(context);
    String? storedValue = hiveData.givenameValue ?? "Loading...";
    String? storedValue58 = hiveData.givename58Value ?? "Loading...";
    String? storedValue80 = hiveData.givename80Value ?? "Loading...";

    setState(() {
      isChecked = true;
      isChecked = storedValue == 'Checked';
      isChecked58 = storedValue58 == 'Checked';
      isChecked80 = storedValue80 == 'Checked';
    });
  }

  void _onCheckbox58Changed(bool? value) {
    setState(() {
      isChecked58 = value ?? false;
      if (isChecked58) {
        isChecked80 = false; // Uncheck 80 mm if 58 mm is checked
      }
      addToHive58(isChecked58 ? 'Checked' : 'Unchecked');
      addToHive80(isChecked80 ? 'Checked' : 'Unchecked');
    });
  }

  void _onCheckbox80Changed(bool? value) {
    setState(() {
      isChecked80 = value ?? false;
      if (isChecked80) {
        isChecked58 = false; // Uncheck 58 mm if 80 mm is checked
      }
      addToHive80(isChecked80 ? 'Checked' : 'Unchecked');
      addToHive58(isChecked58
          ? 'Checked'
          : 'Unchecked'); // Update Hive for 58 mm as well
    });
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });

    addToHive(isChecked ? 'Checked' : 'Unchecked').then((_) {
      print("💾 บันทึกค่าใน Hive เสร็จแล้ว");
    });
  }

  Future<void> addToHive(String GiveName) async {
    Provider.of<QueueProvider>(context, listen: false)
        .setGiveNameValue(GiveName);
    setState(() {});
  }

 


  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    // Load previously connected device address from Hive
    var PrinterBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = PrinterBox.get('PrinterDevice');
    await PrinterBox.close();

    if (savedAddress != null) {
      BluetoothDevice? savedDevice = devices.firstWhere(
        (device) => device.address == savedAddress,
      );

      if (savedDevice != null) {
        if (mounted) {
          setState(() {
            _connected = true;
            _device = savedDevice;
          });
        }

        // Attempt to connect to the saved device
        bluetooth.connect(savedDevice).then((_) {
          if (mounted) {
            setState(() {
              _connected = true;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _connected = false;
            });
          }
        });
      }
    }

    bluetooth.onStateChanged().listen((state) {
      if (mounted) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            setState(() {
              _connected = true;
              print("bluetooth device state: connected");
            });
            break;
          case BlueThermalPrinter.DISCONNECTED:
            setState(() {
              _connected = false;
              print("bluetooth device state: disconnected");
            });
            break;
          // Handle other states
          default:
            print(state);
            break;
        }
      }
    });

    if (mounted) {
      setState(() {
        _devices = devices;
      });
    }

    if (isConnected == true) {
      if (mounted) {
        setState(() {
          _connected = true;
        });
      }
    }
  }

  Future<void> loadFromHive() async {
    var box = await Hive.openBox('savedDataBox');
    List<dynamic>? loadedData = box.get('savedData');

    if (loadedData != null && loadedData.isNotEmpty) {
      setState(() {
        savedData = List<Map<String, String>>.from(
            loadedData.map((e) => Map<String, String>.from(e)));
      });

      // โหลดค่าล่าสุดจาก savedData
      line1 = savedData[0]['line1'];
      line2 = savedData[0]['line2'];
      line3 = savedData[0]['line3'];
    }
  }

// บันทึกข้อมูลใหม่ลงใน savedDataBox
  Future<void> saveToHive() async {
    var box = await Hive.openBox('savedDataBox');

    // Clear any existing data in the box
    await box.clear();

    // Save only the current data
    var currentData =
        savedData; // assuming savedData contains the current data you want to store
    await box.put('savedData', currentData);
  }

  void _addOrUpdateItem(String? line1, String? line2, String? line3) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // If we're not editing an existing item, we replace the saved data
        savedData = [
          {
          'line1': line1Controller.text.isNotEmpty ? line1Controller.text : '',
          'line2': line2Controller.text.isNotEmpty ? line2Controller.text : '',
          'line3': line3Controller.text.isNotEmpty ? line3Controller.text : '',
        }
        ];
      });

      saveToHive(); // ใช้ await เพื่อให้แน่ใจว่าบันทึกแล้ว
      loadFontFromAsset();
      generateImageFromSavedData(savedData); // ✅ แปลงข้อความเป็นรูปภาพ

      // เคลียร์ฟอร์ม
      line1Controller.clear();
      line2Controller.clear();
      line3Controller.clear();

      // รีเซ็ตโหมดแก้ไข
      editIndex = null;

      // แสดงข้อความแจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                editIndex == null ? 'เพิ่มข้อมูลแล้ว' : 'อัปเดตข้อมูลแล้ว')),
      );
    }
  }

  // 🔄 ฟังก์ชันสำหรับแก้ไขข้อมูล
  void _editItem(int index) {
    setState(() {
      editIndex = index;
      line1Controller.text = savedData[index]['line1']!;
      line2Controller.text = savedData[index]['line2']!;
      line3Controller.text = savedData[index]['line3']!;
    });
  }

  @override
  void dispose() {
    super.dispose();
    bluetooth.disconnect(); // Ensure disconnection on dispose
    loadFromHive();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      appBar: AppBar(
        title: const Text(
          'เลือกเครื่องพิมพ์ | ฟอร์มกรอกข้อมูลร้าน',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ส่วน Dropdown เลือกอุปกรณ์
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Device:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButton<BluetoothDevice>(
                          isExpanded: true,
                          items: _getDeviceItems(),
                          onChanged: (BluetoothDevice? value) =>
                              setState(() => _device = value),
                          value: _device,
                          hint: const Text('เลือกอุปกรณ์'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ปุ่ม Refresh และ Connect
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    onPressed: () {
                      initPlatformState();
                    },
                    child: const Text('Refresh',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _connected ? Colors.red : Colors.green,
                    ),
                    onPressed: _connected ? _disconnect : _connect,
                    child: Text(
                      _connected ? 'Connected' : 'Connect',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(   mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: _onCheckboxChanged,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                    'ไม่ต้องการเพิ่มจำนวนลูกค้า\nGive Name & Phone In Numpad',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: isChecked80,
                      onChanged: _onCheckbox80Changed,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text('80 mm.',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: isChecked58,
                      onChanged: _onCheckbox58Changed,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text('58 mm.',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),

              // ปุ่ม Print Test
              Center(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: () {
                    testPrint.sample(savedData);
                  },
                  child: const Text('PRINT TEST',
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 30),

              // ส่วนฟอร์มกรอกข้อมูลร้าน
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: line1Controller,
                          decoration: const InputDecoration(
                              labelText: 'line1', border: OutlineInputBorder()),
                          validator: (value) => null, // ไม่บังคับกรอก
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: line2Controller,
                          decoration: const InputDecoration(
                              labelText: 'line2', border: OutlineInputBorder()),
                          validator: (value) => null, // ไม่บังคับกรอก
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: line3Controller,
                          decoration: const InputDecoration(
                              labelText: 'line3', border: OutlineInputBorder()),
                          validator: (value) => null, // ไม่บังคับกรอก
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // กำหนดค่าเริ่มต้นเป็นค่าว่างหากไม่มีการกรอกข้อมูล
                            String line1 = line1Controller.text.isNotEmpty
                                ? line1Controller.text
                                : '';
                            String line2 = line2Controller.text.isNotEmpty
                                ? line2Controller.text
                                : '';
                            String line3 = line3Controller.text.isNotEmpty
                                ? line3Controller.text
                                : '';

                            // ส่งค่าต่อไปยังฟังก์ชันบันทึก
                            _addOrUpdateItem(line1, line2, line3);
                          },
                          child: Text(editIndex == null
                              ? 'บันทึกข้อมูล'
                              : 'อัปเดตข้อมูล'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //   // แสดงข้อมูลร้านที่บันทึก
              Text(
                'ข้อมูลบัตรคิว:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: savedData.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(savedData[index]['line1'] ??
                        index.toString()), // ✅ Key ต้องไม่ซ้ำ
                    direction:
                        DismissDirection.endToStart, // ✅ ลากจากขวาไปซ้ายเพื่อลบ
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteAllItems(); // ✅ ลบเมื่อทำการลากสำเร็จ
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          savedData[index]['line1'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(savedData[index]['line2'] ?? ''),
                            Text(savedData[index]['line3'] ?? ''),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editItem(index);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _deleteItem(int index) {
  //   setState(() {
  //     savedData.removeAt(index);
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("ลบรายการสำเร็จ!")),
  //   );
  // }
  void _deleteAllItems() async {
    setState(() {
      savedData.clear(); // ล้างข้อมูลทั้งหมดจาก List
    });

    var box = await Hive.openBox('savedDataBox');
    await box.clear(); // ล้างข้อมูลใน Hive

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ลบข้อมูลสำเร็จ!")),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? ""),
          value: device,
        ));
      });
    }
    return items;
  }

  // void _connect() async {
  //   if (_device != null) {
  //     bool? isConnected = await bluetooth.isConnected;
  //     if (!isConnected!) {
  //       bluetooth.connect(_device!).then((_) async {
  //         var PrinterBox = await Hive.openBox('PrinterDevice');
  //         await PrinterBox.put('PrinterDevice', _device!.address);
  //         await PrinterBox.close();
  //         if (mounted) {
  //           setState(() => _connected = true);
  //         }
  //       }).catchError((error) {
  //         if (mounted) {
  //           setState(() => _connected = false);
  //         }
  //       });
  //     }
  //   } else {
  //     show('No device selected.');
  //   }
  // }

  // void _disconnect() {
  //   bluetooth.disconnect();
  //   if (mounted) {
  //     setState(() => _connected = false);
  //   }
  // }
  void _connect() async {
    if (_device != null) {
      // ตรวจสอบสถานะการเชื่อมต่อปัจจุบัน
      bool? isConnected = await bluetooth.isConnected;

      // ถ้ายังเชื่อมต่ออยู่แต่เครื่องที่เชื่อมต่อไม่ตรงกับ _device ที่เลือกใหม่
      if (isConnected == true) {
        // ตัดการเชื่อมต่อเครื่องปัจจุบันก่อน
        _disconnect();
        // รอสักครู่ก่อนเชื่อมต่อเครื่องใหม่
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // เชื่อมต่อกับเครื่องที่เลือก
      bluetooth.connect(_device!).then((_) async {
        // บันทึก address ของเครื่องใหม่ใน Hive
        var printerBox = await Hive.openBox('PrinterDevice');
        await printerBox.put('PrinterDevice', _device!.address);
        await printerBox.close();

        if (mounted) {
          setState(() {
            _connected = true;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _connected = false;
          });
        }
      });
    } else {
      show('No device selected.');
    }
  }

  void _disconnect() async {
    // ตัดการเชื่อมต่อจาก bluetooth
    bluetooth.disconnect();

    // เคลียร์ค่าเครื่องที่บันทึกไว้ใน Hive
    var printerBox = await Hive.openBox('PrinterDevice');
    await printerBox.delete('PrinterDevice');
    await printerBox.close();

    if (mounted) {
      setState(() {
        _connected = false;
      });
    }
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          duration: duration,
        ),
      );
    }
  }
}
