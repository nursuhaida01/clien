// import 'package:client/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'package:flutter_blue/flutter_blue.dart';


// import 'client.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<HomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<HomePage> {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   ClientController clientController = Get.put(ClientController());
//   final textController = TextEditingController();
//   List<String> messages = [];
//   // FlutterBlue flutterBlue = FlutterBlue.instance;
//   // List<BluetoothDevice> devices = [];
//   bool isScanning = false;

//  @override
// void initState() {
//   super.initState();
//   clientController.getIpAddresses(); // 🔍 เริ่มต้นค้นหาเซิร์ฟเวอร์อัตโนมัติ
// }


//   // ฟังก์ชันเริ่มต้นการค้นหา Bluetooth devices
//   // void startScan() {
//   //   setState(() {
//   //     isScanning = true;
//   //   });

//   //   flutterBlue.scanResults.listen((List<ScanResult> results) {
//   //     setState(() {
//   //       devices = results.map((result) => result.device).toList();
//   //     });
//   //   });

//   //   flutterBlue.startScan(timeout: Duration(seconds: 4));
//   // }

//   // // ฟังก์ชันหยุดการค้นหาเมื่อออกจากหน้า
//   // @override
//   // void dispose() {
//   //   flutterBlue.stopScan();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ClientController>(builder: (controller) {
//       return Scaffold(
//          appBar: AppBar(
//         title: const Text('การเชื่อม'),
//         backgroundColor: const Color.fromARGB(255, 17, 145, 185),  centerTitle: true,
//        automaticallyImplyLeading: true

//       ),
//         key: _scaffoldKey,
      
//         body: Column(
//           children: <Widget>[
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
//                 child: Column(
//                   children: <Widget>[
//                     if (controller.clientModels.isEmpty ||
//                         !controller.clientModels.first.isConnected)
//                       Column(
//                         children: [
//                           InkWell(
//                             onTap: () async {
//                               try {
//                                 // ตรวจสอบว่ามี clientModels อย่างน้อยหนึ่งตัว
//                                 if (controller.clientModels.isNotEmpty) {
//                                   // เชื่อมต่อกับ clientModels ตัวแรก
//                                   await controller.clientModels.first.connect();

//                                   // ดึงข้อมูล deviceInfo
//                                   final info = await deviceInfo.androidInfo;

//                                   // ตรวจสอบว่า info มีค่า
//                                   if (info != null) {
//                                     // ส่งข้อความ "Connected to..." พร้อมข้อมูลอุปกรณ์
//                                     controller.sendMessage(
//                                         "Connected to ${info.board} ${info.device}");
//                                     debugPrint(
//                                         "Connected to ${info.board} ${info.device}");
//                                   } else {
//                                     debugPrint("Device info is null.");
//                                   }
//                                 } else {
//                                   debugPrint(
//                                       "No client models available to connect.");
//                                 }
//                               } catch (e) {
//                                 // ดักจับข้อผิดพลาดและแสดงข้อความใน debug console
//                                 debugPrint(
//                                     "Error during connection or device info retrieval: $e");
//                               } finally {
//                                 // อัปเดต UI หลังจากกระบวนการเสร็จสิ้น
//                                 setState(() {});
//                               }
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.all(10.0),
//                               child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         if (controller.addresses.isEmpty)
//                                           Text("No Device Found")
//                                         else
//                                           Column(
//                                             children: [
//                                               const Text(
//                                                 "Desktop",
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 controller.addresses[0]
//                                                     .ip, // แสดง IP Address ของอุปกรณ์แรก
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                       ])),
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const SizedBox(
//                                   width: 30,
//                                   height: 30,
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.lightBlue),
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 TextButton.icon(
//                                   style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all(
//                                         Colors.blue[400]),
//                                   ),
//                                   // onPressed: () {
//                                   //     print("aaa"); // เมื่อกดจะปริ้น aaa
//                                   //   },
//                                   onPressed: controller.getIpAddresses,
//                                   icon: const Icon(
//                                     Icons.search,
//                                     color: Colors.white,
//                                   ),
//                                   label: const Text(
//                                     "Search",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       )
//                     else
//                       Text(
//                           "Connected to ${controller.clientModels.first.hostname}"),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         const Text(
//                           "Client",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 18),
//                         )
//                       ],
//                     ),
//                    ],
//                 ),
//               ),
//             ),

//             const Divider(
//               height: 30,
//               thickness: 1,
//               color: Colors.black12,
//             ),
            
//             // Message Section
//           ],
//         ),
//       );
//     });
//   }
// } 