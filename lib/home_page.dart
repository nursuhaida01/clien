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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late TabController _tabController;
  final filteredQueues1Notifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final filteredQueues3Notifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final filteredQueuesANotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ สังเกตการเปลี่ยนแปลง
    _tabController = TabController(length: 3, vsync: this);
    _refreshPage(); // ✅ โหลดข้อมูลครั้งแรก
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ ยกเลิก Observer
    _tabController.dispose();
    super.dispose();
  }

  // ✅ ฟังก์ชันนี้จะถูกเรียกเมื่อกลับมาหน้านี้
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPage();
    }
  }

  // ✅ ฟังก์ชันสำหรับโหลดข้อมูลใหม่
  Future<void> _refreshPage() async {
    setState(() {
      filteredQueues1Notifier.value = [];
      filteredQueues3Notifier.value = [];
      filteredQueuesANotifier.value = [];
    });

    // จำลองการโหลดข้อมูลใหม่
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      filteredQueues1Notifier.value = [{'queue_no': 'A001'}];
      filteredQueues3Notifier.value = [{'queue_no': 'B002'}];
      filteredQueuesANotifier.value = [{'queue_no': 'C003'}];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF099FAF), Color(0xFF046D8E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 255, 246, 246),
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'เรียกคิว'),
            Tab(text: 'คิวรอ'),
            Tab(text: 'คิวพัก'),
          ],
        ),
      ),
      drawer: const SidebarMenu(),
      body: TabBarView(
        controller: _tabController,
        children: [
          Tab1(
            filteredQueues1Notifier: filteredQueues1Notifier,
            filteredQueues3Notifier: filteredQueues3Notifier,
            filteredQueuesANotifier: filteredQueuesANotifier,
          ),
          Tab2(
            tabController: _tabController,
            filteredQueues1Notifier: filteredQueues1Notifier,
            filteredQueues3Notifier: filteredQueues3Notifier,
            filteredQueuesANotifier: filteredQueuesANotifier,
          ),
          Tab3(
            tabController: _tabController,
            filteredQueues1Notifier: filteredQueues1Notifier,
            filteredQueues3Notifier: filteredQueues3Notifier,
            filteredQueuesANotifier: filteredQueuesANotifier,
          ),
        ],
      ),
    );
  }
}
