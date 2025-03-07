import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../client.dart';

class ClientController extends GetxController {
  List<ClientModel> clientModels = [];
  List<String> logs = [];
  Stream<NetworkAddress>? stream;
  List<NetworkAddress> addresses = [];
  final NetworkInfo _networkInfo = NetworkInfo();
  String? connectedIP;
  RxBool isSearching = false.obs;
  RxBool isConnected = false.obs;

  @override
  void onInit() {
    getIpAddresses();
    super.onInit();
  }

  // / ✅ **ค้นหา IP Address อัตโนมัติ**
  getIpAddresses() async {
    final List<int> portsToScan = [9000, 9001, 9002]; // ระบุพอร์ตที่ต้องการสแกน
    final List<String> subnetsToScan = [
      "192.168.0",
      "192.168.1",
      "192.168.60"
    ]; // ระบุเน็ตเวิร์กของพอร์ตที่ต้องการสแกน

    for (final subnet in subnetsToScan) {
      for (final port in portsToScan) {
        // สร้าง Stream สำหรับสแกน IP Address ในพอร์ตที่กำหนด
        stream = NetworkAnalyzer.discover2(subnet, port);
        await for (NetworkAddress networkAddress in stream!) {
          if (networkAddress.exists) {
            // Check if the IP address already exists in the list
            bool isExisting =
                addresses.any((address) => address.ip == networkAddress.ip);
            if (!isExisting) {
              try {
                final socket = await Socket.connect(networkAddress.ip, port,
                    timeout: const Duration(milliseconds: 100));
                socket.destroy(); // ปิดการเชื่อมต่อ
                debugPrint("${networkAddress.ip}:${port}");
              } catch (e) {
                debugPrint(
                    " ${networkAddress.ip}:${port}, Error: $e");
              }
              // Close the connection
              addresses.add(networkAddress);
              final clientModel = ClientModel(
                hostname: networkAddress.ip,
                onData: OnData,
                onError: onError,
                port: port,
                onStatusChange: (data) {},
              );
              clientModels.add(clientModel);
              update();
            }
          }
        }
      }
    }
  }


  /// ✅ บันทึก IP ล่าสุดที่เชื่อมต่อได้
  Future<void> saveLastConnectedIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_connected_ip', ip);
  }

  /// ✅ ดึง IP ล่าสุดที่เคยใช้
  Future<String?> getLastConnectedIP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_connected_ip');
  }

  /// ✅ ส่งข้อความไปยังเซิร์ฟเวอร์ที่เชื่อมต่ออยู่
  void sendMessage(String message) {
    logs.add(message);
    for (final clientModel in clientModels) {
      clientModel.write(message);
    }
    update();
  }

  OnData(Uint8List data) {
    final message = String.fromCharCodes(data);
    logs.add(message);
    update();
  }

  onError(dynamic error) {
    debugPrint("Error : $error");
  }
  Future<void> connectToServer(String ip) async {
  const int targetPort = 9000; // พอร์ตที่ต้องการเชื่อมต่อ

  try {
    final socket = await Socket.connect(ip, targetPort, timeout: const Duration(milliseconds: 200));
    socket.destroy(); // ปิดการเชื่อมต่อหลังจากตรวจสอบสำเร็จ

    final clientModel = ClientModel(
      hostname: ip,
      onData: OnData,
      onError: onError,
      port: targetPort,
      onStatusChange: (data) {},
    );

    clientModels.add(clientModel);
    update();
    debugPrint("✅ เชื่อมต่อกับเซิร์ฟเวอร์ที่ $ip สำเร็จ");
  } catch (e) {
    debugPrint("❌ ไม่สามารถเชื่อมต่อกับ $ip");
  }
}

  void findServer() {}

}
