import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'printerenum.dart';

class PrintNewAP {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (e) {
      print("Error getting bonded devices: $e");
    }

    var printerBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = printerBox.get('PrinterDevice');

    if (savedAddress != null) {
      try {
        BluetoothDevice? savedDevice = devices.firstWhere(
          (device) => device.address == savedAddress,
        );

        if (savedDevice != null) {
          _device = savedDevice;

          try {
            await bluetooth.connect(savedDevice);
            _connected = true;
            print("Connected to the Bluetooth device");
          } catch (e) {
            _connected = false;
            print("Failed to connect: $e");
          }
        }
      } catch (e) {
        print("Saved device not found in bonded devices list: $e");
      }
    } else {
      print("กรุณาไปหน้าตั้งค่าเพื่อทำการเลือกเครื่องพิมพ์ก่อน");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          _connected = true;
          print("Bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
          _connected = false;
          print("Bluetooth device state: disconnected");
          break;
        default:
          print(state);
          break;
      }
    });

    _devices = devices;

    if (isConnected == true) {
      _connected = true;
    }
  }

  Future<Uint8List> generateTextImage(String text) async {
    // สร้างภาพสำหรับข้อความภาษาไทย
    img.Image image = img.Image(400, 100);
    img.fill(image, img.getColor(255, 255, 255));

    img.drawString(image, img.arial_24, 20, 40, text,
        color: img.getColor(0, 0, 0));

    return Uint8List.fromList(img.encodePng(image));
  }

  Future<void> printThaiText(String text) async {
    Uint8List imageBytes = await generateTextImage(text);
    bluetooth.printImageBytes(imageBytes);
  }

  Future<void> sample(BuildContext context, dynamic queue,
      List<Map<String, String>> savedData) async {
    String filename = 'images-v (1).jpg';
    ByteData bytesData = await rootBundle.load("assets/logo/images-v (1).jpg");
    String dir = (await getApplicationDocumentsDirectory()).path;
    await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    // โหลดรูปภาพโลโก้
    ByteData bytesAsset = await rootBundle.load("assets/logo/logoap.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    // ปรับขนาดรูปภาพ
    img.Image? image = img.decodeImage(imageBytesFromAsset);
    img.Image resizedImage = img.copyResize(image!, width: 271, height: 152);
    Uint8List resizedImageBytes =
        Uint8List.fromList(img.encodeJpg(resizedImage));

    print("คิว: $queue");
    await initPlatformState();

    // แปลงวันที่เป็นรูปแบบ พ.ศ.
    DateTime parsedDate = DateTime.parse(queue.queueDatetime);
    int buddhistYear = parsedDate.year + 543;
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    formattedDate = formattedDate.replaceFirst(
        parsedDate.year.toString(), buddhistYear.toString());
    // ตรวจสอบการเชื่อมต่อ Bluetooth
    if (_connected) {
      bluetooth.printImageBytes(resizedImageBytes);
      bluetooth.printNewLine();

      bluetooth.printCustom("${queue.queueNo}", Size.extraLarge.val, Align.center.val);
      bluetooth.printNewLine();

      bluetooth.printCustom("${queue.queueNumber}PAX", Size.boldMedium.val, Align.center.val);
      bluetooth.printNewLine();

      // Debug: แสดงข้อมูล savedData
      print("Debug savedData: $savedData");

      // พิมพ์ข้อมูล savedData ชุดเดียว
   
        bluetooth.printCustom('${savedData[0]['line1']}', Size.bold.val, Align.center.val);
        bluetooth.printNewLine();

        bluetooth.printCustom('${savedData[0]['line2']}', Size.bold.val, Align.center.val);
        bluetooth.printNewLine();

        bluetooth.printCustom('${savedData[0]['line3']}', Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
      
        print("No data found in savedData.");
      
      // bluetooth.printNewLine();
      bluetooth.printCustom(" $formattedDate", Size.bold.val, Align.center.val);
      bluetooth.printNewLine();
      bluetooth.paperCut();
      print("Printing completed.");
    } else {
      print("Bluetooth is not connected.");
    }
  }
}
