import 'package:client/client.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api/ClassCaller.dart';
import '../api/Queue.dart';
import '../coding/dialog.dart';
import '../database/db_helper.dart';
import '../loadingsreen.dart';
import '../model/queue_model.dart';
import '../providers/dataProvider.dart';

class Tab2 extends StatefulWidget {
  const Tab2({
    super.key,
    required this.tabController,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab2State createState() => _Tab2State();
  final TabController tabController;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab2State extends State<Tab2> {
  bool _isLoading = false;
    bool isChecked = false;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<QueueModel> queueList = [];
  late ClientModel clientModel;
    List<Map<String, String>> savedData = [];

  String formatTime(String? datetime) {
    if (datetime == null || datetime.isEmpty) {
      return "ไม่ระบุเวลา"; // กรณีไม่มีค่า
    }
    DateTime dateTime = DateTime.parse(datetime);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
      // ✅ ดึง IP จาก Hive
    loadSavedIpAndConnect();
      initPlatformState();
      loadFromHive();
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
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    const double fontSize = 16;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Scaffold(
          body: FutureBuilder<List<QueueModel>>(
            future: DatabaseHelper.instance.queryByStatus("รอรับบริการ"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('ไม่มีข้อมูลในระบบ'));
              }

              final data = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final queue = data[index];

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildText(
                                      "${queue.queueNo}",
                                      fontSize * 1.5,
                                      Color(0xFF099FAF),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _buildText(
                                      "Name: ${queue.customerName}",
                                      fontSize,
                                      Color(0xFF099FAF),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _buildText(
                                      "Phone: ${queue.customerPhone}",
                                      fontSize,
                                      Color(0xFF099FAF),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                  // const SizedBox(width: 5),
                                  // Expanded(
                                  //   flex: 1,
                                  //   child: _buildText(
                                  //     "Wait\n",
                                  //     fontSize,
                                  //     const Color.fromARGB(255, 144, 148, 148),
                                  //   ),
                                  // ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 1,
                                    child: _buildElevatedButton(
                                      'End',
                                      const Color.fromARGB(255, 255, 0, 0),
                                      buttonHeight,
                                      (context) async {
                                        await _endQueue(context, queue.toMap());
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 1,
                                    child: _buildElevatedButton(
                                      'Call',
                                      Color(0xFF099FAF),
                                      buttonHeight,
                                      (context) async {
                                        await _callQueue(context, queue);
                                        // final message = queue.queueNo;
                                        //   clientModel.write(message);
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  // เมื่อกดปุ่มใน Dialog ให้เรียกใช้ updateQueueAndNavigate โดยส่งค่าที่ถูกต้อง

  static Future<void> showReasonDialog(
    BuildContext context, {
    required String queueNumber,
    required List<Map<String, dynamic>> queues,
    required Function(String) onActionSelected,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final screenHeight = MediaQuery.of(dialogContext).size.height;
        bool isLoading = false; // Track loading state

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: screenWidth * 0.8,
                height: screenHeight * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display Queue Number
                    Text(
                      "Queue Number : $queueNumber",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(9, 159, 175, 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Show loading spinner if isLoading is true
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else
                      Column(
                        children: [
                          // Accept Service Button
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              // Perform action
                              await Future.delayed(const Duration(
                                  seconds: 1)); // Simulate action
                              onActionSelected("รับบริการ");

                              setState(() {
                                isLoading = false;
                              });
                              // ✅ แสดง Dialog แจ้งเตือนหลังจากอัปเดตสถานะ
                              await DialogHelper.showInfoDialog(
                                context: context,
                                title: "สำเร็จ",
                                message: "อัปเดตสถานะเรียบร้อยแล้ว",
                                icon: Icons.check_circle,
                              );

                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(screenWidth * 0.6, screenHeight * 0.08),
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "รับบริการ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Cancel Service Button
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              // Perform action
                              await Future.delayed(const Duration(
                                  seconds: 1)); // Simulate action
                              onActionSelected("ยกเลิก");

                              setState(() {
                                isLoading = false;
                              });
                              await DialogHelper.showInfoDialog(
                                context: context,
                                title: "สำเร็จ",
                                message: "อัปเดตสถานะเรียบร้อยแล้ว",
                                icon: Icons.check_circle,
                              );

                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(screenWidth * 0.6, screenHeight * 0.08),
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              "ยกเลิก",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Close Dialog Button
                          ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(screenWidth * 0.6, screenHeight * 0.08),
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              "ปิดหน้าต่าง",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _endQueue(
      BuildContext context, Map<String, dynamic> queue) async {
    await showReasonDialog(
      context,
      queueNumber: queue['queue_no'],
      queues: [queue],
      onActionSelected: (String action) async {
        await _updateQueueStatus(context, [queue], action);
      },
    );
  }

  static Future<void> _updateQueueStatus(
    BuildContext context,
    List<Map<String, dynamic>> T2OK,
    String status,
  ) async {
    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (T2OK.isNotEmpty) {
      // ดึง ID ของคิวที่ตรงกับสถานะ "กำลังเรียกคิว"
      int? queueId = T2OK
              .where((queue) => queue['queue_status'] == 'รอรับบริการ')
              .isNotEmpty
          ? T2OK.firstWhere(
              (queue) => queue['queue_status'] == 'รอรับบริการ')['id']
          : null;

      if (queueId != null) {
        try {
          // อัปเดตสถานะในฐานข้อมูลด้วยค่า `status`
          await DatabaseHelper.instance.updateQueueStatus(queueId, status, now);
        } catch (e) {
          // กรณีเกิดข้อผิดพลาด
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
          );
        }
      } else {
        // กรณีไม่พบคิวที่ต้องการอัปเดต
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบคิวที่มีสถานะ "รอรับบริการ"')),
        );
      }
    }
  }

  Future<void> _callQueue(BuildContext context, QueueModel queue) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
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
            await ClassCaller().CallQueue(
              context: context,
              searchStatus: 'รอรับบริการ',
              queueId: queue.id!,
              serviceId: queue.serviceId!,
            );
           if (clientModel.isConnected) {
            debugPrint("📤 ส่งข้อความไปยัง Client: ${queue.queueNo}");
            clientModel.write(queue.queueNo);
          } else {
            debugPrint("⚠️ ไม่สามารถส่งข้อมูล: client ไม่ได้เชื่อมต่อ");
          }
            widget.tabController.animateTo(0);
          },
        ),
      ),
    );
  }
}
