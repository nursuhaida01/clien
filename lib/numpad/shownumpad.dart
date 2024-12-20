import 'package:flutter/material.dart';

import '../Tabs/TabData.dart';
import '../coding/dialog.dart';
import 'numpad.dart';

class ClassNumpad {
  static Future<void> showNumpad(
      BuildContext context, Map<String, dynamic> T1, int? serviceIds) async {
    // ดึง TabData สำหรับข้อมูลสาขาและเคาน์เตอร์
    final tabData = TabData.of(context);

    // ตรวจสอบว่า tabData ไม่เป็น null
    if (tabData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ข้อมูลไม่พร้อมใช้งาน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ดึงค่าของ branches และ counters
    final String branchValue = tabData.branches as String; // ใช้ String จาก TabData
    final String counterValue = tabData.counters as String; // ใช้ String จาก TabData

    // แสดง Numpad Dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Numpad(
                          onSubmit: (pax, name, phone) async {
                            try {
                            

                              // แสดงข้อความสำเร็จ
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('คิวถูกสร้างสำเร็จ'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              // แสดงข้อความเมื่อเกิดข้อผิดพลาด
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('เกิดข้อผิดพลาด: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          T1: T1, serviceIds: serviceIds,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
