import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../api/callqueue.dart';
import '../client.dart';
import '../coding/dialog.dart';
import '../database/db_helper.dart';
import '../loadingsreen.dart';
import '../model/queue_model.dart';

class Tab3 extends StatefulWidget {
  const Tab3({
    super.key,
    required this.tabController,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab3State createState() => _Tab3State();
  final TabController tabController;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab3State extends State<Tab3> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<QueueModel> queueList = [];
  bool _isLoading = true;
  late ClientModel clientModel;
     List<Map<String, String>> savedData = [];

  @override
  void initState() {
    super.initState();
    _loadQueueData();
      // ✅ ดึง IP จาก Hive
    loadSavedIpAndConnect();
  }
 // ✅ ฟังก์ชันสำหรับดึง IP Address จาก Hive และเชื่อมต่อ
  Future<void> loadSavedIpAndConnect() async {
    var box = await Hive.openBox('ipBox'); // เปิด Hive Box
    String savedIp = box.get('savedIP',
        defaultValue: '192.168.0.104'); // ถ้าไม่มี IP จะใช้ค่า Default

    print("🌐 IP ที่ดึงจาก Hive: $savedIp");

    // ✅ สร้าง ClientModel โดยใช้ IP ที่ดึงมา
    clientModel = ClientModel(
      hostname: savedIp, // ใช้ IP จาก Hive
      port: 9000,
      onData: (data) {
        debugPrint('📥 Data received: ${String.fromCharCodes(data)}');
      },
      onError: (error) {
        debugPrint('❌ Error: $error');
      },
      onStatusChange: (status) {
        debugPrint('🔄 Status: $status');
      },
    );

    // ✅ เชื่อมต่อกับ Server
    clientModel.connect();
    print("✅ เชื่อมต่อกับ Server สำเร็จ!");
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
  void saveToHive() async {
    var box = Hive.box('savedDataBox');
    await box.put('savedData', savedData);
  }

  Future<void> _loadQueueData() async {
    try {
      final queues = await dbHelper.queryByStatus("พักคิว");
      setState(() {
        queueList = queues; // เก็บข้อมูลใน state
        _isLoading = false; // ปิดสถานะกำลังโหลด
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // ปิดสถานะกำลังโหลดเมื่อเกิดข้อผิดพลาด
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    }
  }

  String formatTime(String? datetime) {
    if (datetime == null || datetime.isEmpty) {
      return "ไม่ระบุเวลา"; // กรณีไม่มีค่า
    }
    DateTime dateTime = DateTime.parse(datetime);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    const double fontSize = 20; // ขนาดฟอนต์

    return _isLoading
        ? const Center(child: CircularProgressIndicator()) // แสดงสถานะกำลังโหลด
        : queueList.isEmpty
            ? const Center(child: Text('ไม่มีข้อมูลในระบบ')) // ไม่มีข้อมูล
            : ListView.builder(
                itemCount: queueList.length,
                itemBuilder: (context, index) {
                  final queue = queueList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'สถานะ: ${queue.queueStatus}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: queue.queueStatus == "รอรับบริการ"
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildText(
                                    "${queue.queueNo}",
                                    fontSize * 1.5,
                                    const Color(0xFF099FAF),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildText(
                                    "Name: ${queue.customerName}",
                                    fontSize,
                                    const Color(0xFF099FAF),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildText(
                                    "Phone: ${queue.customerPhone}",
                                    fontSize,
                                    const Color(0xFF099FAF),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildText(
                                    "Number\n${queue.queueNumber} PAX",
                                    fontSize,
                                    const Color.fromARGB(255, 144, 148, 148),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: _buildText(
                                    "Queue\n${formatTime(queue.queueDatetime)}",
                                    fontSize,
                                    const Color.fromARGB(255, 144, 148, 148),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: _buildElevatedButton(
                                    'End',
                                    const Color.fromARGB(255, 255, 0, 0),
                                    buttonHeight,
                                    (context) async {
                                      await _endQueue(context, queue);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: _buildElevatedButton(
                                    'Call',
                                    const Color(0xFF099FAF),
                                    buttonHeight,
                                    (context) async {
                                      await _callQueue(context, queue);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildText(String text, double size, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildElevatedButton(
    String label,
    Color color,
    double height,
    Future<void> Function(BuildContext) onPressed,
  ) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () => onPressed(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Future<void> _showReasonDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด Dialog โดยการแตะนอก Dialog
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(dialogContext).pop(); // ปิด Dialog หลัง 3 วินาที
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
                  Icon(icon, color: Colors.red, size: 70),
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

  Future<void> _endQueue(BuildContext context, QueueModel queue) async {
    setState(() {
      _isLoading = true; // เปิดสถานะกำลังโหลด
    });

    try {
      final db = await DatabaseHelper.instance.database;

      // อัปเดตสถานะในฐานข้อมูลเป็น "จบคิว"
      final rowsAffected = await db.update(
        'queue_tb', // ชื่อตาราง
        {'queue_status': 'จบคิว'}, // ค่าใหม่ที่ต้องการอัปเดต
        where: 'queue_no = ?', // เงื่อนไขสำหรับระบุคิว
        whereArgs: [queue.queueNo], // ใช้ queueNo ของคิว
      );

      if (rowsAffected > 0) {
        // แสดง Dialog ว่าอัปเดตสำเร็จ
        await _showReasonDialog(
          context,
          'End Queue',
          'Queue ${queue.queueNo} has been ended successfully.',
          Icons.check_circle,
        );

        // รีเฟรชข้อมูลในหน้าปัจจุบัน
        setState(() {
          _loadQueueData(); // เรียกฟังก์ชันโหลดข้อมูลใหม่
        });
      } else {
        // กรณีไม่พบคิวที่ต้องการอัปเดต
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบคิวที่ต้องการอัปเดต')),
        );
      }
    } catch (error) {
      // กรณีเกิดข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // ปิดสถานะกำลังโหลด
      });
    }
  }

 Future<void> _callQueue(BuildContext context, QueueModel queue) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LoadingScreen(
        onComplete: () async {
          debugPrint("🎯 อัปเดตคิวหลังจากโหลดเสร็จสิ้น...");

          // ✅ ตรวจสอบว่ามีคิวกำลังเรียกอยู่ก่อนอัปเดตคิว
          final existingCallingQueue = await dbHelper.getCallingQueueByService(queue.serviceId!);

          if (existingCallingQueue != null) {
            debugPrint("⚠️ มีคิวกำลังเรียกอยู่ใน Service ID: ${queue.serviceId}");
            await DialogHelper.showCustomDialog(
              context,
              "แจ้งเตือน",
              "⚠️ มีคิวกำลังเรียกอยู่ กรุณาเคลียร์คิวก่อน",
              Icons.warning,
            );
            return; // ❌ หยุดการทำงานที่นี่
          }

          // ✅ ถ้าไม่มีคิวกำลังเรียก -> อัปเดตคิว
          await Class().UpdateQueue(
            context: context,
            searchStatus: 'พักคิว',
            queueId: queue.id!,
            serviceId: queue.serviceId!,
          );

          // ✅ ตรวจสอบ clientModel ก่อนส่งข้อมูล
          if (clientModel.isConnected) {
            debugPrint("📤 ส่งข้อความไปยัง Client: ${queue.queueNo}");
            clientModel.write(queue.queueNo);
          } else {
            debugPrint("⚠️ ไม่สามารถส่งข้อมูล: client ไม่ได้เชื่อมต่อ");
          }

          // ✅ กลับไปที่แท็บแรก
          widget.tabController.animateTo(0);
        },
      ),
    ),
  );
}
}
