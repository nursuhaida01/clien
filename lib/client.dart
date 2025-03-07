import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

typedef Uint8ListCallback = Function(Uint8List data);
typedef DynamicCallback = Function(dynamic data);

final deviceInfo = DeviceInfoPlugin();

class ClientModel {
  String hostname;
  int port;
  Uint8ListCallback onData;
  DynamicCallback onError;
  DynamicCallback onStatusChange;
  Socket? socket;

  bool isConnected = false;
  String connectionStatus = "Disconnected";

  ClientModel({
    required this.hostname,
    required this.onData,
    required this.onError,
    required this.port,
    required this.onStatusChange,
  });

  /// ✅ **ค้นหาเซิร์ฟเวอร์อัตโนมัติ** และเชื่อมต่อ
  static Future<ClientModel?> autoConnect({
    required int port,
    required Uint8ListCallback onData,
    required DynamicCallback onError,
    required DynamicCallback onStatusChange,
  }) async {
    final networkInfo = NetworkInfo();
    String? wifiIP = await networkInfo.getWifiIP();

    if (wifiIP == null) {
      debugPrint("❌ ไม่สามารถดึง IP Address ของเครือข่ายได้");
      return null;
    }

    String subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
    debugPrint("🔍 ค้นหา Server ในเครือข่าย: $subnet.xxx:$port");

    final stream = NetworkAnalyzer.discover2(subnet, port);
    await for (final NetworkAddress addr in stream) {
      if (addr.exists) {
        debugPrint("✅ พบเซิร์ฟเวอร์ที่ ${addr.ip}");

        final client = ClientModel(
          hostname: addr.ip,
          port: port,
          onData: onData,
          onError: onError,
          onStatusChange: onStatusChange,
        );

        await client.connect();
        return client;
      }
    }

    debugPrint("❌ ไม่พบเซิร์ฟเวอร์ในเครือข่าย");
    return null;
  }

  /// ✅ **เชื่อมต่อไปยังเซิร์ฟเวอร์**
  Future<void> connect() async {
    if (isConnected) {
      debugPrint("✅ เชื่อมต่อไปแล้ว: $hostname:$port");
      return;
    }

    try {
      connectionStatus = "🔄 กำลังเชื่อมต่อ...";
      onStatusChange(connectionStatus);

      socket = await Socket.connect(hostname, port)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("❌ การเชื่อมต่อล้มเหลว: Timeout");
      });

      connectionStatus = "✅ เชื่อมต่อสำเร็จ: $hostname:$port";
      isConnected = true;
      onStatusChange(connectionStatus);

      socket!.listen(
        (Uint8List data) {
          final message = String.fromCharCodes(data).trim();
          if (message.isNotEmpty) {
            onData(data);
            debugPrint("📩 ข้อมูลจากเซิร์ฟเวอร์: $message");
          }
        },
        onError: (error) {
          connectionStatus = "❌ ข้อผิดพลาด: $error";
          onStatusChange(connectionStatus);
          socket!.destroy();
          isConnected = false;
        },
        onDone: () {
          connectionStatus = "❌ การเชื่อมต่อถูกปิดโดยเซิร์ฟเวอร์";
          onStatusChange(connectionStatus);
          isConnected = false;
        },
      );
    } catch (e) {
      connectionStatus = "❌ ไม่สามารถเชื่อมต่อ: $e";
      onStatusChange(connectionStatus);
      isConnected = false;
    }
  }
  /// 🛠️ **ฟังก์ชันเชื่อมต่อใหม่อัตโนมัติ**
Future<void> reconnect() async {
  if (isConnected) return; // ถ้าเชื่อมต่ออยู่แล้ว ไม่ต้อง reconnect

  debugPrint("🔄 กำลังพยายามเชื่อมต่อใหม่...");
  await Future.delayed(const Duration(seconds: 3)); // ⏳ รอ 5 วินาที

  connect(); // ลองเชื่อมต่อใหม่
}


  /// ✅ **ส่งข้อความไปยังเซิร์ฟเวอร์**
  void write(String message) {
    if (socket != null && isConnected) {
      socket!.write(message);
      debugPrint("📤 ส่งข้อความ: $message");
    } else {
      debugPrint("❌ ไม่สามารถส่งข้อความ: ไม่มีการเชื่อมต่อ");
    }
  }

  /// ✅ **ตัดการเชื่อมต่อ**
  void disconnect() {
    try {
      socket?.destroy();
      isConnected = false;
      connectionStatus = "❌ ตัดการเชื่อมต่อแล้ว";
      onStatusChange(connectionStatus);
    } catch (e) {
      debugPrint("❌ ข้อผิดพลาดขณะตัดการเชื่อมต่อ: $e");
    }
  }
}
