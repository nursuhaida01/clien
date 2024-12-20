import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';


class Tab2 extends StatefulWidget {
  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<QueueModel> queueList = [];
  List<String> queues = []; // ตัวแปรเก็บคิว
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];
  List<Map<String, dynamic>> queueAll = [];
  List<Map<String, dynamic>> filteredQueues = []; // สำหรับเก็บข้อมูลกรอง

  

  void initState() {
    super.initState();
   
  }
  
  Widget _buildText(String text, double size, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          // fontWeight: FontWeight.bold,
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
    const double fontSize = 16; // กำหนดขนาดฟอนต์
   
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
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map((queue) {
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
                                  
                                  Text(
                                    'servisce: ${queue.serviceId}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
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
                                      "Q ${queue.id}",
                                      fontSize * 1.5,
                                      Color(0xFF099FAF),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _buildText(
                                      // (hiveData.givenameValue == 'Checked')
                                      //     ? formatName(
                                      //         "N:${widget.item['customer_name'] ?? ''}")

                                          // : '',
                                            "Name:${queue.customerName}",
                                      fontSize,
                                      Color(0xFF099FAF),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _buildText(
                                      // (hiveData.givenameValue == 'Checked')
                                      //     ? "T:${widget.item['phone_number'] ?? ''}"
                                      //     : "",
                                       "Phone:${queue.customerPhone} ",
                                   
                                      fontSize,
                                      Color(0xFF099FAF),
                                    ),
                                  ),
                                ],
                              ),
                              // เพิ่มปุ่ม 2 ปุ่ม
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
                                      "Queue\n${queue.queueDatetime}",
                                      fontSize,
                                      const Color.fromARGB(255, 144, 148, 148),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 1,
                                    child: _buildText(
                                      "Wait\n",
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
                                        // Logic สำหรับเมื่อกดปุ่ม End
                                        print('End Queue Button Pressed');
                                        // หากคุณมีฟังก์ชัน _endQueue อยู่แล้ว
                                        // เรียกใช้มันแทน
                                        // _endQueue();
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
                                        // Logic สำหรับเมื่อกดปุ่ม End
                                        print('End Queue Button Pressed');
                                        // หากคุณมีฟังก์ชัน _endQueue อยู่แล้ว
                                        // เรียกใช้มันแทน
                                        // _endQueue();
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
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
