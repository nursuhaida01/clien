// import 'package:flutter/material.dart';
// import '../api/callqueue.dart';
// import '../database/db_helper.dart';
// import '../loadingsreen.dart';
// import '../model/queue_model.dart';

// class Tab3 extends StatefulWidget {
//   const Tab3({
//     super.key,
//     required this.tabController,
//     required this.filteredQueues1Notifier,
//     required this.filteredQueues3Notifier,
//     required this.filteredQueuesANotifier,
//   });

//   @override
//   _Tab3State createState() => _Tab3State();
//   final TabController tabController;
//   final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
//   final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
//   final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
// }

// class _Tab3State extends State<Tab3> {
//   bool _isLoading = false;
//   final DatabaseHelper dbHelper = DatabaseHelper.instance;
//   List<QueueModel> queueList = [];
//   List<String> queues = []; // ตัวแปรเก็บคิว
//   List<Map<String, dynamic>> filteredQueues1 = [];
//   List<Map<String, dynamic>> filteredQueues3 = [];
//   List<Map<String, dynamic>> filteredQueuesA = [];
//   List<Map<String, dynamic>> queueAll = [];
//   List<Map<String, dynamic>> filteredQueues = []; // สำหรับเก็บข้อมูลกรอง
//   List<QueueModel> T2OK = [];
//   @override
//   void initState() {
//     super.initState();
//     _loadQueueData(); // โหลดข้อมูลใน initState
//   }
//    Future<void> _loadQueueData() async {
//     try {
//       final queues = await dbHelper.queryByStatus("พักคิว");
//       setState(() {
//         queueList = queues; // เก็บข้อมูลใน state
//         _isLoading = false; // ปิดสถานะกำลังโหลด
//       });
//     } catch (error) {
//       setState(() {
//         _isLoading = false; // ปิดสถานะกำลังโหลดเมื่อเกิดข้อผิดพลาด
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
//       );
//     }
//   }
//   String formatTime(String? datetime) {
//     if (datetime == null || datetime.isEmpty) {
//       return "ไม่ระบุเวลา"; // กรณีไม่มีค่า
//     }
//     DateTime dateTime = DateTime.parse(datetime);
//     return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
//   }

//   Widget _buildText(String text, double size, Color color) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: size,
//           // fontWeight: FontWeight.bold,
//           color: color,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildElevatedButton(
//     String label,
//     Color color,
//     double height,
//     Future<void> Function(BuildContext) onPressed,
//   ) {
//     return SizedBox(
//       height: height,
//       child: ElevatedButton(
//         onPressed: () => onPressed(context),
//         style: ElevatedButton.styleFrom(
//           foregroundColor: Colors.white,
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(
//           label,
//           style: const TextStyle(
//             fontSize: 20,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final buttonHeight = size.height * 0.06;
//     const double fontSize = 20; // กำหนดขนาดฟอนต์

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
//       child: Container(
//         padding: const EdgeInsets.all(2.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10.0),
//           border: Border.all(color: Colors.white, width: 1.0),
//         ),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator()) // กำลังโหลด
//             : Scaffold(
//                 body: FutureBuilder<List<QueueModel>>(
//                   future: DatabaseHelper.instance.queryByStatus("พักคิว"),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(
//                           child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return const Center(child: Text('ไม่มีข้อมูลในระบบ'));
//                     }

//                     final data = snapshot.data!;
//                     return SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: data.map((queue) {
                         
//                           return Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Card(
//                               elevation: 3,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const SizedBox(height: 8.0),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'สถานะ: ${queue.queueStatus}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: queue.queueStatus ==
//                                                     "รอรับบริการ"
//                                                 ? Colors.orange
//                                                 : Colors.green,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16.0),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       children: [
//                                         Expanded(
//                                           flex: 1,
//                                           child: _buildText(
//                                             "${queue.queueNo}",
//                                             fontSize * 1.5,
//                                             Color(0xFF099FAF),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: _buildText(
//                                             // (hiveData.givenameValue == 'Checked')
//                                             //     ? formatName(
//                                             //         "N:${widget.item['customer_name'] ?? ''}")

//                                             // : '',
//                                             "Name:${queue.customerName}",
//                                             fontSize,
//                                             Color(0xFF099FAF),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: _buildText(
//                                             // (hiveData.givenameValue == 'Checked')
//                                             //     ? "T:${widget.item['phone_number'] ?? ''}"
//                                             //     : "",
//                                             "Phone:${queue.customerPhone} ",

//                                             fontSize,
//                                             Color(0xFF099FAF),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     // เพิ่มปุ่ม 2 ปุ่ม
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       children: [
//                                         Expanded(
//                                           flex: 1,
//                                           child: _buildText(
//                                             "Number\n${queue.queueNumber} PAX",
//                                             fontSize,
//                                             const Color.fromARGB(
//                                                 255, 144, 148, 148),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 5),
//                                         Expanded(
//                                           flex: 1,
//                                           child: _buildText(
//                                             "Queue\n${formatTime(queue.queueDatetime)}",
//                                             fontSize,
//                                             const Color.fromARGB(
//                                                 255, 144, 148, 148),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 5),
//                                         Expanded(
//                                           flex: 1,
//                                           child: _buildText(
//                                             "Wait\n",
//                                             fontSize,
//                                             const Color.fromARGB(
//                                                 255, 144, 148, 148),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 5),
//                                         Expanded(
//                                           flex: 1,
//                                           child: _buildElevatedButton(
//                                             'End',
//                                             const Color.fromARGB(
//                                                 255, 255, 0, 0),
//                                             buttonHeight,
//                                             (context) async {
//                                               await _endQueue(context,
//                                                   queue); // ส่งข้อมูลคิวปัจจุบัน
//                                             },
//                                           ),
//                                         ),
//                                         const SizedBox(width: 5),
//                                         Expanded(
//                                           flex: 1,
//                                           child: _buildElevatedButton(
//                                             'Call',
//                                             Color(0xFF099FAF),
//                                             buttonHeight,
//                                              (context) async {
//                                               await _callQueue(context,
//                                                   queue); // ส่งข้อมูลคิวปัจจุบัน
//                                             },
//                                             // _callQueue,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ),
//     );
//   }

//   // เมื่อกดปุ่มใน Dialog ให้เรียกใช้ updateQueueAndNavigate โดยส่งค่าที่ถูกต้อง
//   Future<void> _showReasonDialog(
//     BuildContext context,
//     String title,
//     String message,
//     IconData icon,
//   ) async {
//     showDialog<void>(
//       context: context,
//       barrierDismissible: false, // ป้องกันการปิด Dialog โดยการแตะนอก Dialog
//       builder: (BuildContext dialogContext) {
//         Future.delayed(const Duration(seconds: 3), () {
//           Navigator.of(dialogContext).pop(); // ปิด Dialog หลัง 3 วินาที
//         });
//         return Center(
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Icon(icon, color: Colors.red, size: 70),
//                   const SizedBox(height: 10),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     message,
//                     style: const TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _endQueue(BuildContext context, QueueModel queue) async {
//     setState(() {
//       _isLoading = true; // เปิดสถานะกำลังโหลด
//     });

//     try {
//       final db = await DatabaseHelper.instance.database;

//       // อัปเดตสถานะในฐานข้อมูลเป็น "จบคิว"
//       final rowsAffected = await db.update(
//         'queue_tb', // ชื่อตาราง
//         {'queue_status': 'จบคิว'}, // ค่าใหม่ที่ต้องการอัปเดต
//         where: 'queue_no = ?', // เงื่อนไขสำหรับระบุคิว
//         whereArgs: [queue.queueNo], // ใช้ queueNo ของคิว
//       );

//       if (rowsAffected > 0) {
//         // แสดง Dialog ว่าอัปเดตสำเร็จ
//         await _showReasonDialog(
//           context,
//           'End Queue',
//           'Queue ${queue.queueNo} has been ended successfully.',
//           Icons.check_circle,
//         );

//         // รีเฟรชข้อมูลในหน้าปัจจุบัน
//         setState(() {
//           _loadQueueData(); // เรียกฟังก์ชันโหลดข้อมูลใหม่
//         });
//       } else {
//         // กรณีไม่พบคิวที่ต้องการอัปเดต
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('ไม่พบคิวที่ต้องการอัปเดต')),
//         );
//       }
//     } catch (error) {
//       // กรณีเกิดข้อผิดพลาด
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // ปิดสถานะกำลังโหลด
//       });
//     }
//   }

// // ฟังก์ชันโหลดข้อมูลใหม่
//   // Future<void> _loadQueueData() async {
//   //   try {
//   //     final queues = await DatabaseHelper.instance.queryByStatus("พักคิว");
//   //     setState(() {
//   //       queueList = queues; // อัปเดตข้อมูลในตัวแปร
//   //     });
//   //   } catch (error) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $error')),
//   //     );
//   //   }
//   // }

//  Future<void> _callQueue(BuildContext context, QueueModel queue) async {
//   // ✅ เรียกใช้ LoadingScreen ก่อนอัปเดตคิว
//   await Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => LoadingScreen(
//         onComplete: () async {
//           debugPrint("🎯 อัปเดตคิวหลังจากโหลดเสร็จสิ้น...");
//           await Class().UpdateQueue(
//             context: context,
//             searchStatus: 'พักคิว',
//             queueId: queue.id!,
//             serviceId: queue.serviceId!,
//           );
//            widget.tabController.animateTo(0);
//         },
//       ),
//     ),
//   );
// }

// }
