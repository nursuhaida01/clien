import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

typedef Unit8ListCallback = Function(Uint8List data);
typedef DynamicCallback = Function(dynamic data);


class ClientModel {
  String hostname;
  int port;
  Unit8ListCallback onData;
  DynamicCallback onError;
  DynamicCallback onStatusChange; // Callback สำหรับการเปลี่ยนสถานะ
  WebSocket? _socket;
  List<String> messages = [];

  ClientModel({
    required this.hostname,
    required this.onData,
    required this.onError,
    required this.port,
    required this.onStatusChange,
  });

  bool isConnected = false;
  String connectionStatus = "Disconnected";
  Socket? socket;

 Future<void> connect() async {
  if (isConnected) {
    debugPrint("Already connected to $hostname:$port");
    return;
  }

  try {
    connectionStatus = "Connecting...";
    onStatusChange(connectionStatus);

    // Attempt to connect with timeout
    socket = await Socket.connect(hostname, port)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception("Connection timeout to $hostname:$port");
    });

    connectionStatus = "$hostname:$port";
    isConnected = true;
    onStatusChange(connectionStatus);

    // Listen to server messages
    socket!.listen(
      (Uint8List data) {
        final message = String.fromCharCodes(data).trim();
        if (message.isNotEmpty) {
          messages.add("Server: $message");
          onData(data);
          debugPrint("Message received from server: $message");
        }
      },
      onError: (error) {
        connectionStatus = "Error: $error";
        onStatusChange(connectionStatus);
        socket!.destroy();
        isConnected = false;
      },
      onDone: () {
        isConnected = false;
        connectionStatus = "Connection closed by server.";
        onStatusChange(connectionStatus);
      },
    );
  } catch (e) {
    connectionStatus = "Connection failed: $e";
    onStatusChange(connectionStatus);
    isConnected = false;
  }
}

  

  void write(String message) {
    if (socket != null && isConnected) {
      socket!.write(message);
      messages.add("client: $message"); // บันทึกข้อความของไคลเอนต์
    } else {
      debugPrint("Cannot send message. No active connection.");
    }
  }

 }
