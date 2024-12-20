import 'package:flutter/material.dart';

import 'Service/Service.dart';
import 'Status/Status.dart';
import 'display_data_page.dart';
import 'scanner/home_screen.dart';
import 'sender.dart';
import 'setting/setting.dart';
import 'tabs/tes.dart';


class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[200], // สีพื้นหลังของ Sidebar
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 54, 137, 200), Color.fromARGB(255, 8, 181, 234)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 40,
                      color: Color.fromRGBO(9, 159, 175, 1.0),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'เมนูการใช้งาน',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color.fromRGBO(9, 159, 175, 1.0),),
              title: const Text(
                'หน้าแรก',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer
              },
            ),
            const Divider(thickness: 1, indent: 16, endIndent: 16), // เส้นแบ่ง
            ListTile(
              leading: const Icon(Icons.queue, color: Color.fromRGBO(9, 159, 175, 1.0),),
              title: const Text(
                'รายการคิว',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  DisplayDataPage()), // ไปยังหน้าการตั้งค่า
              );
              },
            ),
             const Divider(thickness: 1, indent: 16, endIndent: 16), // เส้นแบ่ง
            ListTile(
              leading: const Icon(Icons.miscellaneous_services, color: Color.fromRGBO(9, 159, 175, 1.0),),
              title: const Text(
                'ตั้งค่าservis',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AddServicePage()), // ไปยังหน้าการตั้งค่า
              );
              },
            ),
            const Divider(thickness: 1, indent: 16, endIndent: 16), // เส้นแบ่ง
           ListTile(
              leading: const Icon(Icons.print, color: Colors.deepPurple),
              title: const Text(
                'Printer Setting',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
              Navigator.pop(context); // ปิด Drawer
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const SettingScreen()), // ไปยังหน้าการตั้งค่า
              // );
            },
            ),
            const Divider(thickness: 1, indent: 16, endIndent: 16), // เส้นแบ่ง
            ListTile(
              leading: const Icon(Icons.queue, color: Color.fromRGBO(9, 159, 175, 1.0),),
              title: const Text(
                'ปริ้น',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  SenderApp()), // ไปยังหน้าการตั้งค่า
              );
              },
            ),
             ListTile(
              leading: const Icon(Icons.queue, color: Color.fromRGBO(9, 159, 175, 1.0),),
              title: const Text(
                'Status',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AddStatusPage()), // ไปยังหน้าการตั้งค่า
              );
              },
            ),
             ListTile(
              leading: const Icon(Icons.queue, color: Color.fromRGBO(9, 159, 175, 1.0),),
              title: const Text(
                'Status',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  HomePage(title: '',)), // ไปยังหน้าการตั้งค่า
              );
              },
            ),
          ],
        ),
      ),
    );
  }
}
