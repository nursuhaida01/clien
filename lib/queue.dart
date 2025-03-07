import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';
import 'coding/dialog.dart';
import 'home_page.dart';
import 'providers/dataProvider.dart';
import 'providers/queue_provider.dart';

class DisplayDataPage extends StatefulWidget {
  const DisplayDataPage({Key? key}) : super(key: key);

  @override
  _DisplayDataPageState createState() => _DisplayDataPageState(); // ✅ เพิ่มเมธอดนี้
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  bool _isLoading = false; // สำหรับแสดงสถานะกำลังโหลด
   // ✅ เพิ่มตัวแปร ValueNotifier เพื่อจัดการกับการอัปเดตข้อมูล
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier = ValueNotifier([]);
  List<Map<String, dynamic>> T2OK = []; // ✅ ประกาศตัวแปร T2OK
Map<dynamic, List<Map<String, dynamic>>> TQOKK = {}; // ✅ ประกาศตัวแปร TQOKK


  String formatTimeOnly(String? datetime) {
    if (datetime == null || datetime.isEmpty) {
      return "ไม่ระบุเวลา"; // กรณีไม่มีค่า
    }
    DateTime dateTime = DateTime.parse(datetime);

    // ใช้ padLeft(2, '0') เพื่อให้ชั่วโมงและนาทีเป็น 2 หลักเสมอ
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }

//  Future<void> clearAllQueues(BuildContext context) async {
//   try {
//     setState(() {
//       _isLoading = true;
//     });

//     await DatabaseHelper.instance.clearAll('queue_tb');
//     final provider = Provider.of<QueueProvider>(context, listen: false);
//     await provider.reloadServices();
//     provider.notifyListeners();

//     // ✅ อัปเดตข้อมูลใน ValueNotifier
//     filteredQueues1Notifier.value = [];
//     filteredQueues3Notifier.value = [];
//     filteredQueuesANotifier.value = [];

//     // ✅ แจ้งเตือน Widget ที่ฟัง ValueNotifier ให้รีเฟรช
//     filteredQueues1Notifier.notifyListeners();
//     filteredQueues3Notifier.notifyListeners();
//     filteredQueuesANotifier.notifyListeners();

//     await DialogHelper.showInfoDialog(
//       context: context,
//       title: "สำเร็จ",
//       message: "เคลียร์ข้อมูลสำเร็จ",
//       icon: Icons.check_circle,
//     );

//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const DisplayDataPage()),
//     );

//     setState(() {
//       _isLoading = false;
//     });
//   } catch (e) {
//     await DialogHelper.showInfoDialog(
//       context: context,
//       title: "เกิดข้อผิดพลาด",
//       message: "ข้อผิดพลาด: $e",
//       icon: Icons.error,
//     );

//     setState(() {
//       _isLoading = false;
//     });
//   }
// }
 Future<void> clearAllQueues(BuildContext context) async {
    try {
      await DatabaseHelper.instance.clearAll('queue_tb'); // ✅ ลบข้อมูลทั้งหมด
      final provider = Provider.of<QueueProvider>(context, listen: false);
      await provider.reloadServices(); // โหลดข้อมูลใหม่
      provider.notifyListeners(); // แจ้งให้ UI รีเฟรช
 setState(() {
      T2OK.clear();   
      TQOKK.clear();  
    });
      // ✅ แสดง Dialog แจ้งเตือนว่าลบสำเร็จ และปิดเองหลัง 2 วินาที
      await DialogHelper.showInfoDialog(
        context: context,
        title: "สำเร็จ",
        message: " เคลียร์ข้อมูลสำเร็จ", // ✅ เปลี่ยนข้อความ
        icon: Icons.check_circle,
      );

      // ✅ เปลี่ยนหน้าไปยัง DisplayDataPage() หลัง Dialog ปิด
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DisplayDataPage()),
      );
    } catch (e) {
      // ✅ แสดง Dialog แจ้งเตือนข้อผิดพลาด
      await DialogHelper.showInfoDialog(
        context: context,
        title: "เกิดข้อผิดพลาด",
        message: " ข้อผิดพลาด: $e",
        icon: Icons.error,
      );
    }
  }


  Color _getStatusColor(String status) {
    const statusColors = {
      "พักคิว": Color.fromARGB(255, 255, 140, 0), // 🟧 สีส้มเข้ม
      "ยกเลิก": Color.fromARGB(255, 220, 20, 60), // 🔴 สีแดงเข้ม
      "รับบริการ": Color.fromARGB(255, 34, 139, 34), // 🟢 สีเขียวเข้
      "จบคิว": Color.fromARGB(255, 220, 20, 60), // 🟣 สีม่วง
    };

    return statusColors[status] ?? const Color.fromARGB(255, 144, 148, 148);
  }

  String _getStatusText(String status) {
    switch (status) {
      case "พักคิว":
        return "Hold";
      case "ยกเลิก":
        return "Cancel";
      case "รับบริการ":
        return "End ";
      case "จบคิว":
        return "End";
      default:
        return status; // กรณีอื่นให้ใช้ค่าเดิม
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiveData = Provider.of<DataProvider>(context);
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.05; // 5% ของความสูงหน้าจอ
    final fontSize = size.height * 0.02;
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'รายการคิว',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
  elevation: 0,

  // ✅ เพิ่มปุ่ม Back พร้อมเปลี่ยนสี
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white), // เปลี่ยนสีเป็นขาว
    onPressed: () {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'AP Queue')),
      );
    });
    },
  ),

  actions: [
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.white), // ✅ เปลี่ยนสีไอคอนลบ
      onPressed: () async {
        bool confirm = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: fontSize * 1.5,
                ),
                SizedBox(width: size.width * 0.02),
                Flexible(
                  child: Text(
                    'ยืนยันการลบ',
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            ),
            content: Text(
              'คุณแน่ใจว่าต้องการลบคิวทั้งหมดหรือไม่?\n(ถ้าลบแล้วจะไม่สามารถนำกลับมาได้อีก)',
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
                        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
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
                        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
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

        if (confirm) {
          setState(() {
            _isLoading = true;
          });

          await clearAllQueues(context);
          final provider = Provider.of<QueueProvider>(context, listen: false);
          await provider.reloadServices();

          if (mounted) {
            setState(() {});
          }

          debugPrint('✅ ลบคิวและโหลดข้อมูลใหม่เรียบร้อยแล้ว');
        }
      },
    ),
  ],
),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(9, 159, 175, 1.0),
              Color.fromRGBO(9, 159, 175, 1.0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<QueueModel>>(
          future: DatabaseHelper.instance.queryAll('queue_tb'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'เกิดข้อผิดพลาด: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'ไม่มีข้อมูลในระบบ',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final data = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final queue = data[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8.0),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(15),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildText(
                              " ${queue.queueNo}",
                              fontSize * 1.5,
                              const Color.fromRGBO(9, 159, 175, 1.0),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildText(
                              "N: ${queue.customerName}",
                              fontSize,
                              const Color.fromRGBO(9, 159, 175, 1.0),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildText(
                              "T: ${queue.customerPhone}",
                              fontSize,
                              const Color.fromRGBO(9, 159, 175, 1.0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildText(
                              "Number\n${queue.queueNumber} PAX",
                              fontSize,
                              const Color.fromARGB(255, 144, 148, 148),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildText(
                              "Queue\n${formatTimeOnly(queue.queueCreate ?? "")}",
                              fontSize,
                              const Color.fromARGB(255, 144, 148, 148),
                            ),
                          ),

                          // ✅ แสดงเวลาตามสถานะของคิว พร้อมสีที่ไม่ซ้ำกัน
                          if (["พักคิว", "ยกเลิก", "รับบริการ", "จบคิว"]
                              .contains(queue.queueStatus))
                            Expanded(
                              flex: 1,
                              child: _buildText(
                                "${_getStatusText(queue.queueStatus)}\n${formatTimeOnly(queue.queueDatetime ?? "")}",
                                fontSize,
                                _getStatusColor(queue.queueStatus),
                              ),
                            ),

                          Expanded(
                            flex: 1,
                            child: _buildText(
                              "Status\n${queue.queueStatus}",
                              fontSize,
                              const Color.fromARGB(255, 144, 148, 148),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }
}
