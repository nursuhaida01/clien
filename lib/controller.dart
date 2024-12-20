import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

import 'client.dart';

class ClientController extends GetxController {
  List<ClientModel> clientModels = [];
  List<String> logs = [];
  // int port = 9000;
  Stream<NetworkAddress>? stream;
  List<NetworkAddress> addresses = [];
  final NetworkInfo _networkInfo = NetworkInfo();
  String? connectedIP;
  


  @override
  void onInit() {
    getIpAddresses();
    super.onInit();
  }

  getIpAddresses() async {
  // Replace "192.168.0.100" with the desired IP address
  const targetIP = "192.168.0.110";
  const targetPort = 9000; // Replace with the desired port

  try {
    // Attempt to connect to the specific IP and port
    final socket = await Socket.connect(targetIP, targetPort,
        timeout: const Duration(milliseconds: 100));

    // Close the connection immediately after validating
    socket.destroy();

    // Add the address to the list if the connection is successful
    addresses.add(NetworkAddress(targetIP, true));
    final clientModel = ClientModel(
      hostname: targetIP,
      onData: OnData,
      onError: onError,
      port: targetPort, onStatusChange: (data) {  },
    );

    clientModels.add(clientModel);
    update();
    debugPrint("Connected to $targetIP:$targetPort");
  } catch (e) {
    debugPrint("Failed to connect to $targetIP:$targetPort. Error: $e");
  }
}

  // getIpAddresses() async {
  //   final List<int> portsToScan = [9000, 9001, 9002]; // ระบุพอร์ตที่ต้องการสแกน
  //   final List<String> subnetsToScan = [
  //     "192.168.0",
  //     "192.168.1",
  //     "192.168.60"
  //   ]; // ระบุเน็ตเวิร์กของพอร์ตที่ต้องการสแกน

  //   for (final subnet in subnetsToScan) {
  //     for (final port in portsToScan) {
  //       // สร้าง Stream สำหรับสแกน IP Address ในพอร์ตที่กำหนด
  //       stream = NetworkAnalyzer.discover2(subnet, port);
  //       await for (NetworkAddress networkAddress in stream!) {
  //         if (networkAddress.exists) {
  //           // Check if the IP address already exists in the list
  //           bool isExisting =
  //               addresses.any((address) => address.ip == networkAddress.ip);
  //           if (!isExisting) {
  //             try {
  //               final socket = await Socket.connect(networkAddress.ip, port,
  //                   timeout: const Duration(milliseconds: 100));
  //               socket.destroy(); // ปิดการเชื่อมต่อ
  //               debugPrint("Connected to ${networkAddress.ip}:${port}");
  //             } catch (e) {
  //               debugPrint(
  //                   "Failed to connect to ${networkAddress.ip}:${port}, Error: $e");
  //             }
  //             // Close the connection
  //             addresses.add(networkAddress);
  //             final clientModel = ClientModel(
  //               hostname: networkAddress.ip,
  //               onData: OnData,
  //               onError: onError,
  //               port: port,
  //               onStatusChange: (data) {},
  //             );
  //             clientModels.add(clientModel);
  //             update();
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

  void sendMessage(String message) {
    String formattedDateTime =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    logs.add("Call Pad : $message ($formattedDateTime)");
    for (final clientModel in clientModels) {
      clientModel.write(message);
    }
    update();
  }
// void sendMessage(String message) {
//   if (clientModels.isEmpty) {
//     print("ไม่มี client ที่เชื่อมต่อ");
//     return;
//   }

//   logs.add(message); // เก็บ log
//   for (final clientModel in clientModels) {
//     clientModel.write(message); // ส่งข้อความไปยัง client
//   }
//   print("Message sent: $message");
//    update(); // ตรวจสอบว่า message ถูกส่งแล้ว
// }



  OnData(Uint8List data) {
    final message = String.fromCharCodes(data);
    logs.add(message);
    update();
  }

  onError(dynamic error) {
    debugPrint("Error : $error");
  }
}
