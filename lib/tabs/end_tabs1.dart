import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../coding/dialog.dart';
import '../database/db_helper.dart'; // นำเข้า DatabaseHelper

class ClassEndTabs1 {
  static Future<void> showReasonDialog(
    BuildContext context,
    List<Map<String, dynamic>> T2OK,
    int serviceId, // เพิ่ม serviceId เพื่อกรองข้อมูล
  ) async {
    bool _isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final screenHeight = MediaQuery.of(dialogContext).size.height;

        return StatefulBuilder(
          builder: (context, setState) {
            // กรองคิวที่ตรงกับ serviceId
            final queuesForService = T2OK
                .where((queue) =>
                    queue['service_id'] == serviceId &&
                    queue['queue_status'] == 'กำลังเรียกคิว')
                .toList();

            // ดึงคิวแรกของ serviceId
            final String queueNumber = queuesForService.isNotEmpty
                ? queuesForService.first['queue_no']
                : 'No Data';
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: screenWidth * 0.8,
                height: screenHeight * 0.4,
                child: Column(
                  children: [
                    // แสดง Queue Number
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

                    // ถ้ากำลังโหลด
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        children: [
                          // ปุ่ม: พักคิว
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                screenWidth * 0.6,
                                screenHeight * 0.08,
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 24, 177, 4),
                            ),
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              try {
                                await _updateQueueStatus(
                                    dialogContext, T2OK, 'พักคิว', serviceId);
                                await DialogHelper.showInfoDialog(context: context, title: "สำเร็จ", message:"อัปเดตสถานะเรียบร้อยแล้ว", icon: Icons.check_circle,);
                              } catch (e) {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            child: const Text(
                              'พักคิว',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ปุ่ม: ยกเลิก
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                screenWidth * 0.6,
                                screenHeight * 0.08,
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 219, 118, 2),
                            ),
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              try {
                                await _updateQueueStatus(
                                    dialogContext, T2OK, 'ยกเลิก', serviceId );
                                await DialogHelper.showInfoDialog(context: context, title: "อัปเดตสถานะยกเลิก", message:"สำเร็จ", icon: Icons.check_circle,);
                              } catch (e) {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            child: const Text(
                              'ยกเลิก',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ปุ่ม: ปิดหน้าต่าง
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                screenWidth * 0.6,
                                screenHeight * 0.08,
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 213, 0, 0),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text(
                              'ปิดหน้าต่าง',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
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

  static Future<void> _updateQueueStatus(
    BuildContext context,
    List<Map<String, dynamic>> T2OK,
    String status,
     int serviceId,
  ) async {
    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (T2OK.isNotEmpty) {
      // ดึง ID ของคิวที่ตรงกับสถานะ "กำลังเรียกคิว"
     int? queueId = T2OK
    .where((queue) => 
       queue['service_id'] == serviceId && 
       queue['queue_status'] == 'กำลังเรียกคิว')
    .isNotEmpty
    ? T2OK.firstWhere(
        (queue) => 
           queue['service_id'] == serviceId && 
           queue['queue_status'] == 'กำลังเรียกคิว')['id']
    : null;


      if (queueId != null) {
        
          // อัปเดตสถานะในฐานข้อมูลด้วยค่า `status`
          await DatabaseHelper.instance.updateQueueStatus(queueId, status, now);
        // ✅ แสดง Dialog ว่าสำเร็จ
      } 
    }
  }

 }
