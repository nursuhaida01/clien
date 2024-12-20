// import 'package:flutter/material.dart';
// import '../database/db_helper.dart';
// import '../model/queue_model.dart';
// import '../numpad/shownumpad.dart';
// import '../providers/queue_provider.dart';
// import 'package:provider/provider.dart';
// import '../model/service_model.dart';
// import 'TabData.dart';

// class Tab1 extends StatefulWidget {
//   @override
//   _Tab1State createState() => _Tab1State();
// }

// class _Tab1State extends State<Tab1> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _deletelController = TextEditingController();
//   bool _isLoading = false;
//   final DatabaseHelper dbHelper = DatabaseHelper.instance;
//   List<QueueModel> queueList = [];
//   List<String> queues = []; // ตัวแปรเก็บคิว
//   List<Map<String, dynamic>> filteredQueues1 = [];
//   List<Map<String, dynamic>> filteredQueues3 = [];
//   List<Map<String, dynamic>> filteredQueuesA = [];
//   List<Map<String, dynamic>> queueAll = [];
//   List<Map<String, dynamic>> filteredQueues = []; // สำหรับเก็บข้อมูลกรอง
//   late Future<int> _queueCountFuture;
//   Map<int, Map<String, dynamic>> _latestQueuesByService = {};
// Map<String, dynamic>? _selectedQueue;

  
//  //ตัวแปรสำหรับเก็บคิวล่าสุดใน

//   Future<void> _fetchQueues() async {
//     final data = await dbHelper.queryAll();
//     setState(() {
//       queueList = data;
//     });
//   }

//   //ฟังก์ชันดึงคิวล่าสุดจากฐานข้อมูล:
// Future<void> _fetchLatestQueuesByService() async {
//   final result = await dbHelper.fetchLatestQueueByService();
//   if (result != null) {
//     setState(() {
//       _latestQueuesByService = result; // อัปเดตคิวแยกตาม service
//     });
//   }
// }


//   // ฟังก์ชันหาคิวที่เก่าสุดของวันนี้

//   Future<void> fetchCallerQueueAll() async {
//     // ตัวอย่างฟังก์ชันดึงข้อมูลทั้งหมด
//     await Future.delayed(const Duration(seconds: 1));
//     print('fetchCallerQueueAll completed');
//   }

//   Future<void> fetchSearchQueue() async {
//     // ตัวอย่างฟังก์ชันค้นหาคิว
//     await Future.delayed(const Duration(seconds: 1));
//     print('fetchSearchQueue completed');
//   }

//   Map<dynamic, int> getCountPerBranchServiceGroup(
//       Map<dynamic, List<Map<String, dynamic>>> TQOKK) {
//     final countMap = <dynamic, int>{};
//     TQOKK.forEach((branchServiceGroupId, queues) {
//       countMap[branchServiceGroupId] = queues.length;
//     });
//     return countMap;
//   }

//   void initState() {
//     super.initState();
//     final provider = Provider.of<QueueProvider>(context, listen: false);
//     provider.fetchServices();
//   }

//   Future<void> _saveService(BuildContext context) async {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() {
//         _isLoading = true;
//       });

//       final provider = Provider.of<QueueProvider>(context, listen: false);
//       final service = ServiceModel(
//         name: _nameController.text.trim(),
//         deletel: _deletelController.text.trim(),
//       );

//       try {
//         await provider.addService(service);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
//         );
//         Navigator.of(context).pop(); // ปิด Dialog
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ข้อมูลตัวอย่างของ TQOKK
//   final Map<dynamic, List<Map<String, dynamic>>> TQOKK = {};

//   @override
//   Widget build(BuildContext context) {
//     final tabData = TabData.of(context);
//     final size = MediaQuery.of(context).size;
//     final buttonHeight = size.height * 0.06;
//     const double fontSize = 16; // กำหนดขนาดฟอนต์
//     final provider = Provider.of<QueueProvider>(context);

//     return Scaffold(
//       body: provider.services.isEmpty
//           ? const Center(
//               child: Text(
//                 'ไม่มีข้อมูลบริการ',
//                 style: TextStyle(fontSize: 18),
//               ),
//             )
//           : ListView.builder(
//               itemCount: provider.services.length,
//               itemBuilder: (context, index) {
//                 final service = provider.services[index];
//                  final latestQueue = _latestQueuesByService[service.id]; // ดึงคิวตาม service_id


//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
//                   child: Card(
//                     elevation: 4,
//                     margin: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 4,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Column(
//                                         children: [
//                                           Text(
//                                             'Service\n${service.deletel}',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .titleLarge
//                                                 ?.copyWith(
//                                                   fontSize: 18, // ปรับขนาดฟอนต์
//                                                   color: const Color.fromRGBO(
//                                                       9, 159, 175, 1.0),
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           const SizedBox(height: 8),
//                                         ],
//                                       ),
//                                       Column(
//                                         children: [
//                                           Text(
//                                             'คิวรอ',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .titleLarge
//                                                 ?.copyWith(
//                                                   fontSize: 18, // ปรับขนาดฟอนต์
//                                                   color: const Color.fromRGBO(
//                                                       9, 159, 175, 1.0),
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           FutureBuilder<int>(
//                                             future: dbHelper
//                                                 .getQueueCountByServiceId(
//                                                     service.id ?? 0),
//                                             builder: (context, snapshot) {
//                                               if (snapshot.connectionState ==
//                                                   ConnectionState.waiting) {
//                                                 return const CircularProgressIndicator(); // แสดงสถานะโหลด
//                                               }
//                                               if (snapshot.hasError) {
//                                                 return const Text(
//                                                   'เกิดข้อผิดพลาด',
//                                                   style: TextStyle(
//                                                       color: Colors.red),
//                                                 );
//                                               }

//                                               final queueCount = snapshot
//                                                       .data ??
//                                                   0; // ดึงจำนวนคิวจาก snapshot
//                                               return Text(
//                                                 '$queueCount', // แสดงจำนวนคิว
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .titleLarge
//                                                     ?.copyWith(
//                                                       fontSize: 19,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color:
//                                                           const Color.fromRGBO(
//                                                               9, 159, 175, 1.0),
//                                                     ),
//                                                 textAlign: TextAlign.center,
//                                               );
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                       Column(
//                                         children: [
//                                           Text(
//                                             'คิวถัดไป',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .titleLarge
//                                                 ?.copyWith(
//                                                   fontSize: 18,
//                                                   color: const Color.fromRGBO(
//                                                       9, 159, 175, 1.0),
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           FutureBuilder<Map<String, dynamic>?>(
//                                             future: dbHelper
//                                                 .getOldestQueueByServiceId(service
//                                                         .id ??
//                                                     0), // ดึงคิวเก่าสุดตาม service.id
//                                             builder: (context, snapshot) {
//                                               if (snapshot.connectionState ==
//                                                   ConnectionState.waiting) {
//                                                 return const CircularProgressIndicator(); // แสดงสถานะโหลด
//                                               }
//                                               if (snapshot.hasError) {
//                                                 return const Text(
//                                                   'เกิดข้อผิดพลาด',
//                                                   style: TextStyle(
//                                                       color: Colors.red),
//                                                 );
//                                               }

//                                               final queue = snapshot
//                                                   .data; // คิวที่ได้จากฐานข้อมูล
//                                               if (queue != null) {
//                                                 return Text(
//                                                   'Q ${queue['id']} (${queue['queue_number']})',
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .titleLarge
//                                                       ?.copyWith(
//                                                         fontSize: fontSize,
//                                                         color: const Color
//                                                             .fromRGBO(
//                                                             9, 159, 175, 1.0),
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                   textAlign: TextAlign.center,
//                                                 );
//                                               } else {
//                                                 return Text(
//                                                   '-',
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .titleLarge
//                                                       ?.copyWith(
//                                                         fontSize: fontSize,
//                                                         color: const Color
//                                                             .fromRGBO(
//                                                             9, 159, 175, 1.0),
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                   textAlign: TextAlign.center,
//                                                 );
//                                               }
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               flex: 3,
//                               child: Container(
//                                 padding: EdgeInsets.all(size.height * 0.01),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: const Color.fromRGBO(
//                                             9, 159, 175, 1.0) ??
//                                         Colors.white,
//                                   ),
//                                   borderRadius: BorderRadius.circular(50),
//                                 ),
//                                 child: Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Column(
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Text(
//                                                 latestQueue != null
//                                                     ? 'คิว: ${latestQueue!['id']} (${latestQueue!['customer_name']})'
//                                                     : '.',
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .titleLarge
//                                                     ?.copyWith(
//                                                       fontSize: 18 * 1.8,
//                                                       color:
//                                                           const Color.fromRGBO(
//                                                               9, 159, 175, 1.0),
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             // ปุ่มเพิ่มคิว
//                             Expanded(
//                               flex: 2,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   setState(() {
//                                     _isLoading = true; // แสดงสถานะโหลด
//                                   });

//                                   try {
//                                     // แสดง numpad
//                                     await ClassNumpad.showNumpad(
//                                         context,
//                                         {'key': 'value'},
//                                         service
//                                             .id); // ส่ง T1 หรือค่าอื่น ๆ หากจำเป็น
//                                   } catch (e) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('เกิดข้อผิดพลาด: $e'),
//                                       ),
//                                     );
//                                   } finally {
//                                     // ดึงข้อมูลทั้งหมดและค้นหาคิวใหม่
//                                     await fetchCallerQueueAll();
//                                     await fetchSearchQueue();
//                                     setState(() {
//                                       _isLoading = false; // ซ่อนสถานะโหลด
//                                     });
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor:
//                                       const Color.fromRGBO(9, 159, 175, 1.0),
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: size.height * 0.02),
//                                   minimumSize:
//                                       Size(double.infinity, buttonHeight),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: _isLoading
//                                     ? const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       )
//                                     : Text(
//                                         'เพิ่มคิว',
//                                         style: TextStyle(
//                                           fontSize: fontSize,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             // ปุ่ม Arrived
//                             Expanded(
//                               flex: 2,
//                               child: ElevatedButton(
//                                 onPressed: () {},
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 24, 177, 4),
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: size.height * 0.00),
//                                   minimumSize:
//                                       Size(double.infinity, buttonHeight),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'รับบริการ',
//                                   style: TextStyle(
//                                       fontSize: 18, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             // ปุ่ม Other
//                             Expanded(
//                               flex: 1,
//                               child: ElevatedButton(
//                                 onPressed: () {},
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 219, 118, 2),
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: size.height * 0.00),
//                                   minimumSize:
//                                       Size(double.infinity, buttonHeight),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'อื่นๆ',
//                                   style: TextStyle(
//                                       fontSize: 18, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             // ปุ่ม Recall
//                             Expanded(
//                               flex: 2,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                     setState(() {
//                                     _isLoading = true; // แสดงสถานะโหลด
//                                   });
//                                   await _fetchLatestQueuesByService(); // ดึงข้อมูลคิวล่าสุดและแสดง
//                                  setState(() {
//                                       _isLoading = false; // ซ่อนสถานะโหลด
//                                     });
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor:
//                                       const Color.fromRGBO(9, 159, 175, 1.0),
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: size.height * 0.00),
//                                   minimumSize:
//                                       Size(double.infinity, buttonHeight),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'เรียกคิว',
//                                   style: TextStyle(
//                                       fontSize: 18, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         // แสดงรายการคิว
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
