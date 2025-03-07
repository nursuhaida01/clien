import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

Future<void> showQRCodeDialog(
    BuildContext context, Map<String, dynamic> _qrData) async {
  var printerBox = await Hive.openBox('PrinterDevice');
  String? printerAddressString = printerBox.get('PrinterDevice');

  if (printerAddressString != null) {
    await _PrintTicket(printerAddressString, _qrData);
  } else {
    print('Printer address is null');
  }
  await printerBox.close();
}

Future<Uint8List> resizeImage(
    Uint8List imageBytes, int width, int height) async {
  final img.Image image = img.decodeImage(imageBytes)!;
  final img.Image resized = img.copyResize(image, width: width, height: height);
  return Uint8List.fromList(img.encodeJpg(resized));
}

Future<void> _PrintTicket(
    String printerAddressString, Map<String, dynamic> _qrData) async {
  try {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);
    final PosPrintResult res = await printer.connect(printerAddressString, port: 9100);

    if (res == PosPrintResult.success) {
      DateTime queueTime = DateTime.parse(_qrData['queue_time']);
      String formattedQueueTime =
          "${queueTime.day}/${queueTime.month}/${queueTime.year} ${queueTime.hour}:${queueTime.minute}";
      final ByteData data = await rootBundle.load("assets/logo/images-v.jpg");
      final Uint8List bytes = data.buffer.asUint8List();

      final Uint8List resizedBytes = await resizeImage(bytes, 450, 150);

      // Print logo
      final img.Image image = img.decodeImage(resizedBytes)!;
      printer.image(image);

      // Print queue number
      printer.text(
        "Queue Number: ${_qrData['queue_no']}",
        styles: PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
      );

      // Print queue time
      printer.text(
        "Time: $formattedQueueTime",
        styles: PosStyles(align: PosAlign.center),
      );

      // Print footer
      printer.text(
        "If your number has passed, Please get a new ticket",
        styles: PosStyles(align: PosAlign.center),
      );

      printer.feed(2);
      printer.cut();

      // Disconnect printer
      printer.disconnect();
    } else {
      print('Could not connect to printer. Result: $res');
    }
  } catch (e) {
    print('Error: $e');
  }
}
