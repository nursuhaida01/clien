import 'package:client/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// import 'package:flutter_blue/flutter_blue.dart';

import '../client.dart';
import 'client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ClientController clientController = Get.put(ClientController());
  final textController = TextEditingController();
  List<String> messages = [];
  // FlutterBlue flutterBlue = FlutterBlue.instance;
  // List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    clientController.getIpAddresses(); // 🔍 เริ่มต้นค้นหาเซิร์ฟเวอร์อัตโนมัติ
  }

  Future<void> saveIpToHive(String ip) async {
    var box = Hive.box('ipBox');
    await box.put('savedIP', ip); // ✅ บันทึก IP ลง Hive
    print("✅ IP ถูกบันทึกใน Hive: $ip");
  }
  // ฟังก์ชันเริ่มต้นการค้นหา Bluetooth devices
  // void startScan() {
  //   setState(() {
  //     isScanning = true;
  //   });

  //   flutterBlue.scanResults.listen((List<ScanResult> results) {
  //     setState(() {
  //       devices = results.map((result) => result.device).toList();
  //     });
  //   });

  //   flutterBlue.startScan(timeout: Duration(seconds: 4));
  // }

  // // ฟังก์ชันหยุดการค้นหาเมื่อออกจากหน้า
  // @override
  // void dispose() {
  //   flutterBlue.stopScan();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('การเชื่อมต่อ Server',  style: TextStyle(color: Colors.white),),
         backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
            centerTitle: true,
            automaticallyImplyLeading: true),
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Column(
                  children: <Widget>[
                    // ✅ แสดงสถานะการค้นหา
                    if (controller.clientModels.isEmpty ||
                        !controller.clientModels.first.isConnected)
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              try {
                                // ตรวจสอบว่ามี clientModels อย่างน้อยหนึ่งตัว
                                if (controller.clientModels.isNotEmpty) {
                                  // เชื่อมต่อกับ clientModels ตัวแรก
                                  await controller.clientModels.first.connect();
                                  // ✅ ดึง IP Address จาก controller
                                  String ip = controller.addresses.isNotEmpty
                                      ? controller.addresses[0].ip
                                      : '0.0.0.0';

                                  // ✅ บันทึก IP ลง Hive หลังจากเชื่อมต่อสำเร็จ
                                  await saveIpToHive(ip);

                                  print("Connected to $ip");
                                  // ดึงข้อมูล deviceInfo
                                  final info = await deviceInfo.androidInfo;

                                  // ตรวจสอบว่า info มีค่า
                                  if (info != null) {
                                    // ส่งข้อความ "Connected to..." พร้อมข้อมูลอุปกรณ์
                                    controller.sendMessage(
                                        "Connected to ${info.board} ${info.device}");
                                    debugPrint(
                                        "Connected to ${info.board} ${info.device}");
                                  } else {
                                    debugPrint("Device info is null.");
                                  }
                                } else {
                                  debugPrint(
                                      "No client models available to connect.");
                                }
                              } catch (e) {
                                // ดักจับข้อผิดพลาดและแสดงข้อความใน debug console
                                debugPrint(
                                    "Error during connection or device info retrieval: $e");
                              } finally {
                                // อัปเดต UI หลังจากกระบวนการเสร็จสิ้น
                                setState(() {});
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (controller.addresses.isEmpty)
                                          Text(
                                            "No Device Found",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )
                                        else
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 20.0),
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.blue.shade50
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 22, 117, 160),
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "Desktop",
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 22, 117, 160),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  controller.addresses[0]
                                                      .ip, // แสดง IP Address ของอุปกรณ์แรก
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ])),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.lightBlue),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                TextButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blue[400]),
                                  ),
                                  // onPressed: () {
                                  //     print("aaa"); // เมื่อกดจะปริ้น aaa
                                  //   },
                                  onPressed: controller.getIpAddresses,
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Search",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                          "Connected to ${controller.clientModels.first.hostname}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          "Client",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Message Section
          ],
        ),
      );
    });
  }
}
