import 'package:client/queue.dart';
import 'package:flutter/material.dart';

import 'Service/Service.dart';
import 'queue/queue.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF099FAF), Color(0xFF099FAF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF099FAF), Color(0xFF099FAF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 40,
                      color: Color(0xFF099FAF),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'การตั้งค่า',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.queue,
                    title: 'Queue list',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayDataPage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.miscellaneous_services,
                    title: 'Service Management',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddServicePage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.print,
                    title: 'Printing',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        // MaterialPageRoute(builder: (context) => SenderApp()),
                         MaterialPageRoute(builder: (context) => const SettingScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.connecting_airports,
                    title: 'Connect to',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(title: '')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF099FAF)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }
}
