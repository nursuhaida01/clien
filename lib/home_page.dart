import 'package:flutter/material.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'settings.dart';
import 'sidebar_menu.dart'; 


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // กำหนดจำนวนแท็บเป็น 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // ไอคอนตั้งค่า
            onPressed: () {
              // เรียก Popup การตั้งค่าจากไฟล์ settings_popup.dart
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const SettingsPopup(); // ใช้ Widget Popup ที่แยกไว้
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'เรียกคิว'),
            Tab(text: 'คิวรอ'),
            Tab(text: 'คิวพัก'),
          ],
        ),
      ),
      drawer: const SidebarMenu(), // Sidebar เมนูด้านซ้าย
      body: TabBarView(
        controller: _tabController,
        children: [
          Tab1(), // ใช้ Tab1Page
          Tab2(), // ใช้ Tab2Page
          Tab3(), // ใช้ Tab3Page
        ],
      ),
    );
  }
  
  
}
