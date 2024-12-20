import 'package:flutter/material.dart';

class TabData {
  final String branches; // ชื่อสาขา
  final String counters; // ชื่อเคาน์เตอร์

  TabData({required this.branches, required this.counters});

  static TabData? of(BuildContext context) {
    // คืนค่าข้อมูลตัวอย่าง
    return TabData(
      branches: 'Branch 1',
      counters: 'Counter 1',
    );
  }
}



