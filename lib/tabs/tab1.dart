import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api/Queue.dart';
import '../client.dart';
import '../coding/dialog.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';
import '../numpad/shownumpad.dart';
import '../print/print_true.dart';
import '../providers/dataProvider.dart';
import '../providers/queue_provider.dart';
import 'end_tabs1.dart';

class Tab1 extends StatefulWidget {
  final int? serviceIds;
  const Tab1({
    super.key,
    this.serviceIds,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab1State createState() => _Tab1State();
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab1State extends State<Tab1> {
  final TextEditingController _paxController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();

  bool _isLoading = false;
  bool isChecked = false;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  Map<dynamic, List<Map<String, dynamic>>> TQOKK = {};
  List<Map<String, dynamic>> T2OK = [];
  List<Map<String, dynamic>> queueAll = [];
  late ClientModel clientModel;
  Map<String, dynamic>? TQOKKK;
  List<Map<String, String>> savedData = [];
  PrintNewAP printnewap = PrintNewAP();

  @override
  void initState() {
    fetchCallerQueueAll();
    fetchSearchQueue();
    reloadAllData();
    super.initState();
    loadTQOKK();
    loadT2OK();
    final provider = Provider.of<QueueProvider>(context, listen: false);
    provider.fetchServices();

    // ✅ ดึง IP จาก Hive
    loadSavedIpAndConnect();
    initPlatformState();
    loadFromHive();
    
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

  Future<void> fetchSearchQueue() async {
    try {
      // ดึงข้อมูลทั้งหมดจากฐานข้อมูลและแปลงเป็น Map
      final queueMaps = (await dbHelper.queryAllQueues())
          .map((queue) => queue.toMap())
          .toList();

      // แสดงผลข้อมูลที่โหลดมา
      print('ฟฟฟ $queueMaps');
    } catch (e) {
      // แสดงข้อผิดพลาด
      debugPrint('Error loading queues: $e');
    }
  }

  Future<void> fetchCallerQueueAll() async {
    // โค้ดสำหรับโหลดข้อมูลคิวทั้งหมด
    try {
      final queues = await dbHelper.queryAllQueues(); // ดึงข้อมูลจากฐานข้อมูล
      setState(() {
        T2OK = queues.map((queue) => queue.toMap()).toList();
      });
      debugPrint("Queues loaded successfully: $T2OK");
    } catch (e) {
      debugPrint("Error fetching queues: $e");
    }
  }

  Future<void> callQueue(String queueNo) async {
    try {
      setState(() {
        _isLoading = true; // แสดงสถานะกำลังโหลด
      });

      // สมมุติว่าคุณมีฟังก์ชันสำหรับเรียกคิว (ตัวอย่างด้านล่าง)
      final response = await dbHelper.callQueueByQueueNo(queueNo!);

      if (response != null) {
        setState(() {
          // เพิ่มคิวที่เรียกไปยัง T2OK
          T2OK.add(response);

          // อัปเดต UI
          debugPrint('Updated T2OK: $T2OK');
        });
      } else {
        debugPrint('No queue found for queueNo: $queueNo');
      }
    } catch (e) {
      debugPrint('Error calling queue: $e');
    } finally {
      setState(() {
        _isLoading = false; // ซ่อนสถานะกำลังโหลด
      });
    }
  }

  Future<void> loadT2OK() async {
    try {
      // ดึงข้อมูลทั้งหมดจากฐานข้อมูลในรูปแบบของ QueueModel
      final List<QueueModel> queues = await dbHelper.queryAllQueues();

      // จัดกลุ่มข้อมูลตาม service_id
      final Map<int, List<Map<String, dynamic>>> groupedByServiceId = {};
      for (var queue in queues) {
        final serviceId =
            queue.serviceId ?? 0; // กรณีไม่มี serviceId จะใช้ค่า 0 แทน
        if (!groupedByServiceId.containsKey(serviceId)) {
          groupedByServiceId[serviceId] = [];
        }
        groupedByServiceId[serviceId]!.add(queue.toMap());
      }

      // อัปเดต state
      setState(() {
        T2OK = queues
            .map((queue) => queue.toMap())
            .toList(); // ใช้แบบเดิมสำหรับทั้งหมด
        TQOKK = groupedByServiceId; // จัดกลุ่มตาม service_id
      });

      debugPrint('T2OK Loaded: $T2OK');
      debugPrint('Grouped by service_id: $TQOKK');
    } catch (e, stackTrace) {
      debugPrint('Error loading T2OK: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> loadTQOKK() async {
    setState(() {
      _isLoading = true; // แสดงสถานะกำลังโหลด
    });

    try {
      final fetchedData = await fetchTQOKK();
      // ตรวจสอบว่าข้อมูลที่ได้มาถูกต้อง
      if (fetchedData.isNotEmpty) {
        setState(() {
          TQOKK = fetchedData;
        });
      } else {
        debugPrint('⚠️ ไม่มีข้อมูลใน TQOKK');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading TQOKK: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false; // ปิดสถานะกำลังโหลด
      });
    }
  }

  Future<Map<dynamic, List<Map<String, dynamic>>>> fetchTQOKK() async {
    try {
      final List<QueueModel> queues = await dbHelper.queryAllQueues();
      final Map<dynamic, List<Map<String, dynamic>>> groupedQueues = {};

      for (var queue in queues) {
        final serviceId = queue.serviceId ?? 0;
        if (!groupedQueues.containsKey(serviceId)) {
          groupedQueues[serviceId] = [];
        }
        groupedQueues[serviceId]!.add(queue.toMap());
      }

      return groupedQueues;
    } catch (e) {
      throw Exception('Error fetching TQOKK: $e');
    }
  }

  Future<void> reloadAllData() async {
    setState(() {
      _isLoading = true; // แสดงสถานะกำลังโหลด
    });
    try {
      // โหลดข้อมูลคิวใหม่
      await loadTQOKK();
      await loadT2OK();

      // รีโหลดข้อมูลจาก Provider
      final provider = Provider.of<QueueProvider>(context, listen: false);
      await provider.reloadServices();
      provider.notifyListeners(); // ✅ แจ้ง Provider ให้อัพเดต UI

      debugPrint('Reloaded all data successfully');
      setState(() {});
    } catch (e) {
      debugPrint('Error reloading data: $e');
    } finally {
      setState(() {
        _isLoading = false; // ปิดสถานะกำลังโหลด
      });
    }
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
    final buttonHeight = size.height * 0.06;
    const double fontSize = 16; // กำหนดขนาดฟอนต์
    final provider = Provider.of<QueueProvider>(context);
    return RefreshIndicator(
       onRefresh: reloadAllData,
      child: Scaffold( 
        body: provider.services.isEmpty
            ? const Center(child: Text('ไม่มีข้อมูลคิว'))
            : ListView.builder(
                itemCount: provider.services.length,
                itemBuilder: (context, index) {
                  final service = provider.services[index];
                  final serviceId = service.serviceId;
                  final hiveData = Provider.of<QueueProvider>(context);
                  final countWaiting = provider.countWaitingByService[serviceId] ?? 0;
                  final queuesOfService = TQOKK[serviceId] ?? [];
                  final waitingOnly = queuesOfService
                      .where((q) => q['queue_status'] == 'รอรับบริการ')
                      .toList();

                  Map<String, dynamic>? TQOKKK;
                  if (waitingOnly.isEmpty) {
                    TQOKKK = null;
                  } else {
                    TQOKKK = waitingOnly.reduce((a, b) {
                      final aQueueNo =
                          a['id']?.toString() ?? ''; // ใช้ default เป็น ''
                      final bQueueNo = b['id']?.toString() ?? '';
                      final aId = int.tryParse(aQueueNo);
                      final bId = int.tryParse(bQueueNo);
                      if (aId == null) return b;
                      if (bId == null) return a;
                      return aId < bId ? a : b;
                    });
                  }
                  if (TQOKKK != null) {
                    print('คิวถัดไป: ${TQOKKK['queue_no']}');
                  } else {
                    print('ไม่มีคิวถัดไป');
                  }
                  // final countPerGroup = getCountWaitingPerService(TQOKK);
                  // // print(TQOKK);

                  final filteredT2OK = T2OK
                      .where(
                          (queueItem) => queueItem['service_id'] == serviceId)
                      .where((queueItem) =>
                          queueItem['queue_status'].contains('กำลังเรียกคิว'))
                      .toList();
                  print("aaaaaaaaaaaaaaaaaaaa");

                  print(filteredT2OK);

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Service\n${service.name}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontSize:
                                                        18, // ปรับขนาดฟอนต์
                                                    color: const Color.fromRGBO(
                                                        9, 159, 175, 1.0),
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'คิวรอ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontSize:
                                                        18, // ปรับขนาดฟอนต์
                                                    color: const Color.fromRGBO(
                                                        9, 159, 175, 1.0),
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              '$countWaiting',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontSize:
                                                        fontSize, // ปรับขนาดฟอนต์
                                                    color: const Color.fromRGBO(
                                                        9, 159, 175, 1.0),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'คิวถัดไป',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontSize: 18,
                                                    color: const Color.fromRGBO(
                                                        9, 159, 175, 1.0),
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (TQOKKK != null)
                                              Text(
                                                '${TQOKKK['queue_no']} (${TQOKKK['queue_number']})',
                                                // Text(
                                                //   '${TQOKKK['id']} (${TQOKKK['queue_number']})',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontSize:
                                                          fontSize, // ปรับขนาดฟอนต์
                                                      color:
                                                          const Color.fromRGBO(
                                                              9, 159, 175, 1.0),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.center,
                                              )
                                            else
                                              Text(
                                                '-',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontSize:
                                                          fontSize, // ปรับขนาดฟอนต์
                                                      color:
                                                          const Color.fromRGBO(
                                                              9, 159, 175, 1.0),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.all(size.height * 0.01),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                              9, 159, 175, 1.0) ??
                                          Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            if (filteredT2OK.isNotEmpty)
                                              ...filteredT2OK.map(
                                                (queue) => Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround, // Spreads the text to opposite ends
                                                  children: [
                                                    if (queue['queue_status'] ==
                                                        'กำลังเรียกคิว')
                                                      Text(
                                                        "${queue['queue_no']}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge
                                                            ?.copyWith(
                                                              fontSize:
                                                                  fontSize *
                                                                      1.8,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  9,
                                                                  159,
                                                                  175,
                                                                  1.0),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                  //    if (hiveData.givenameValue == 'Checked')
                                                  //   Text(
                                                  //     '${(queue['customer_name'] != null && queue['customer_name'].isNotEmpty) ? 'N : ${queue['customer_name']}' : 'N : -'}\n'
                                                  //     '${(queue['customer_phone'] != null && queue['customer_phone'].isNotEmpty) ? 'P : ${queue['customer_phone']}' : 'P : -'}',
                                                  //     style: Theme.of(context)
                                                  //         .textTheme
                                                  //         .titleLarge
                                                  //         ?.copyWith(
                                                  //           fontSize:
                                                  //               fontSize * 1.0,
                                                  //           color: const Color
                                                  //               .fromRGBO(9,
                                                  //               159, 175, 1.0),
                                                  //           // fontWeight:
                                                  //           // FontWeight.bold,
                                                  //         ),
                                                  //     textAlign:
                                                  //         TextAlign.start,
                                                  //   )
                                                  //
                                                  ],
                                                ),
                                              )
                                            else
                                              Text(
                                                '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontSize: fontSize * 1.5,
                                                      color:
                                                          const Color.fromRGBO(
                                                              9, 159, 175, 1.0),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // ปุ่มADD Queue
                                // Expanded(
                                //   flex: 2,
                                //   child: ElevatedButton(
                                //     onPressed: () async {
                                //       // setState(() {
                                //       //   _isLoading = true;
                                //       // });
                                //       try {
                                //         await ClassNumpad.showNumpad(context,
                                //             {'key': 'value'}, service.id);

                                //       } catch (e) {
                                //         ScaffoldMessenger.of(context)
                                //             .showSnackBar(
                                //           SnackBar(
                                //             content: Text('เกิดข้อผิดพลาด: $e'),
                                //           ),
                                //         );
                                //       } finally {

                                //         await Future.delayed(Duration(seconds: 1));

                                //             setState(() {
                                //           _isLoading = false;

                                //         });

                                //         await fetchCallerQueueAll();
                                //         await fetchSearchQueue();
                                //         await provider.reloadServices();
                                //         await reloadAllData();

                                //       }
                                //     },
                                //     style: ElevatedButton.styleFrom(
                                //       foregroundColor: Colors.white,
                                //       backgroundColor:
                                //           const Color.fromRGBO(9, 159, 175, 1.0),
                                //       padding: EdgeInsets.symmetric(
                                //           vertical: size.height * 0.00),
                                //       minimumSize:
                                //           Size(double.infinity, buttonHeight),
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(8),
                                //       ),
                                //     ),
                                //     child: Text(
                                //       'เพิ่มคิว',
                                //       style: TextStyle(
                                //         fontSize: fontSize,
                                //         color: Colors.white,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        // setState(() {
                                        //   _isLoading = true;
                                        // });

                                        final customerName =
                                            _customerNameController.text;
                                        final customerPhone =
                                            _customerPhoneController.text;
                                        final paxText = _controller.text;

                                        if (hiveData.givenameValue == 'Checked') {
                                          // ✅ ถ้าผู้ใช้ติ๊ก → สร้างคิวทันที
                                          final queueNumber =
                                              '-'; // กำหนดเลขคิวเป็น '-'

                                          final queue = QueueModel(
                                            queueNumber: queueNumber,
                                            customerName: customerName,
                                            customerPhone: customerPhone,
                                            queueStatus: 'รอรับบริการ',
                                            queueDatetime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                            queueCreate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                            serviceId: serviceId,
                                            queueNo: '',
                                          );

                                          final insertedId = await DatabaseHelper.instance.insertQueue(queue);
                                          print( "🎫 ID ของคิวที่สร้าง: $insertedId");

                                          final updatedQueue =await DatabaseHelper.instance.getQueueById(insertedId);
                                          print("📋 ข้อมูล Queue ที่ได้จาก Database: $updatedQueue");

                                          await printnewap.sample(context, updatedQueue, savedData);
                                          String queueMessage =
                                              "กำลังพิมพ์บัตรคิว\nPrint Ticket";
                                          await DialogHelper.showInfoDialog(
                                            context: context,
                                            title: queueMessage,
                                            message: "",
                                            icon: Icons.warning,
                                          );
                                        } else {
                                          // ❌ ถ้าผู้ใช้ไม่ติ๊ก → แสดง Numpad ก่อน
                                          print(
                                              "📢 isChecked = false → แสดง Numpad");
                                          try {
                                            await ClassNumpad.showNumpad(
                                                context,
                                                {'key': 'value'},
                                                service.id);
                                          
                                          } catch (e) {
                                            print("❌ Error แสดง Numpad: $e");
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'เกิดข้อผิดพลาดขณะเรียก Numpad: $e')),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('เกิดข้อผิดพลาด: $e')),
                                        );
                                      } finally {
                                        await Future.delayed(Duration(milliseconds: 100));
                                        // setState(() {
                                        //   _isLoading = false;
                                        // });
                                        await fetchCallerQueueAll();
                                        await fetchSearchQueue();
                                        await provider.reloadServices();
                                        await reloadAllData();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromRGBO(
                                          9, 159, 175, 1.0),
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.00),
                                      minimumSize:
                                          Size(double.infinity, buttonHeight),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'เพิ่มคิว',
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                
                                
                                SizedBox(width: size.width * 0.02),
                                if (filteredT2OK.isNotEmpty) ...[
                                  // ปุ่มรับบริการ
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        await ClassCRUD().UpdateQueue(
                                          context: context,
                                          SearchQueue: filteredT2OK,
                                          queueStatus: 'รับบริการ',
                                          StatusQueueNote: '',
                                        );

                                        await Future.wait([
                                          fetchCallerQueueAll(),
                                          fetchSearchQueue(),
                                          reloadAllData(),
                                        ]);

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255, 24, 177, 4),
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.00),
                                        minimumSize:
                                            Size(double.infinity, buttonHeight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'รับบริการ',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: size.width * 0.02),
                                  // ปุ่มอื่นๆ
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          await ClassEndTabs1.showReasonDialog(
                                              context, T2OK, serviceId);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('เกิดข้อผิดพลาด: $e'),
                                            ),
                                          );
                                        } finally {
                                          await fetchCallerQueueAll();
                                          await fetchSearchQueue();
                                          await reloadAllData();

                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255, 219, 118, 2),
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.00),
                                        minimumSize:
                                            Size(double.infinity, buttonHeight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'อื่นๆ',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  // ปุ่มRecall

                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading =
                                              true; // เปิดสถานะกำลังโหลด
                                        });
                                        try {
                                          // ตรวจสอบว่ามีคิวใน filteredT2OK หรือไม่
                                          final selectedQueue =
                                              filteredT2OK.isNotEmpty
                                                  ? filteredT2OK.first
                                                  : null;
                                          if (selectedQueue != null) {
                                            final queueNo =
                                                selectedQueue['queue_no'];
                                            // ใช้ queue_no ในการส่งข้อความและเรียกฟังก์ชัน
                                            final message = "$queueNo";
                                            // โหลดข้อมูลใหม่หลังจากอัปเดตคิว
                                            await fetchSearchQueue();
                                            clientModel.write(
                                                message); // ส่งข้อความไปยัง clientModel
                                          }
                                        } catch (e) {
                                          debugPrint("Error: $e");
                                        } finally {
                                          setState(() {
                                            _isLoading =
                                                false; // ปิดสถานะกำลังโหลด
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromRGBO(
                                            9, 159, 175, 1.0),
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.00),
                                        minimumSize:
                                            Size(double.infinity, buttonHeight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'เรียกซ้ำ',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // ปุ่มรับคิว (ไม่สามารถกดได้)
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255, 117, 117, 117),
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.00),
                                        minimumSize:
                                            Size(double.infinity, buttonHeight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'รับบริการ',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  // ปุ่มOther (ไม่สามารถกดได้)
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255, 117, 117, 117),
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.00),
                                        minimumSize:
                                            Size(double.infinity, buttonHeight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'อื่นๆ',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  // ปุ่มCall
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading =
                                              true; // เปิดสถานะกำลังโหลด
                                        });

                                        try {
                                          final queueNo = TQOKKK != null
                                              ? TQOKKK['queue_no']
                                              : null;

                                          if (queueNo != null) {
                                            // ใช้ queue_no ในการส่งข้อความและเรียกฟังก์ชัน
                                            final message = "$queueNo";
                                            await callQueue(
                                                queueNo); // เรียกฟังก์ชัน callQueue โดยใช้ queue_no

                                            await callQueue(queueNo);
                                            // โหลดข้อมูลใหม่หลังจากอัปเดตคิว
                                            await fetchSearchQueue();
                                            await DialogHelper.showInfoDialog(
                                              context: context,
                                              title: "กำลังเรียกคิว",
                                              message:
                                                  message, // แสดงข้อความที่มี Prefix
                                              icon: Icons.queue,
                                            );
                                            clientModel.write( message); // โหลดข้อมูลใหม่
                                          } else {
                                            // แจ้งเตือนว่าไม่มีคิว
                                            await DialogHelper.showInfoDialog(
                                              context: context,
                                              title: "ไม่มีคิว",
                                              message:
                                                  "ไม่มีคิวที่สามารถเรียกได้ในขณะนี้",
                                              icon: Icons.warning,
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint("Error: $e");
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          await fetchCallerQueueAll();
                                          await fetchSearchQueue();
                                          await provider.reloadServices();
                                          await reloadAllData();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromRGBO(
                                            9, 159, 175, 1.0),
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.00),
                                        minimumSize:
                                            Size(double.infinity, buttonHeight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'เรียกคิว',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
