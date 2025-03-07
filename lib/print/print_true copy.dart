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
    // await printerBox.close();

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
      print("กรุณาไปหน้าตั้งค่าเพื่อทำการ เลือกเครื่องพิมพ์ก่อน");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          _connected = true;
          print("bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
          _connected = false;
          print("bluetooth device state: disconnected");
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
  

  sample(
      BuildContext context, queue, List<Map<String, String>> savedData) async {
    String filename = 'images-v (1).jpg';
    ByteData bytesData = await rootBundle.load("assets/logo/images-v (1).jpg");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    /// Image from Asset
    ByteData bytesAsset = await rootBundle.load("assets/logo/logoap.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);
    // Resize the image
    img.Image? image = img.decodeImage(imageBytesFromAsset);
    img.Image resizedImage = img.copyResize(image!, width: 271, height: 152);
    Uint8List resizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));

    ByteData fontData = await rootBundle.load("assets/fonts/FreeSerif.ttf");
    Uint8List fontBytes = fontData.buffer.asUint8List();

      // ✅ สร้างภาพขนาด 400x100 px
      img.fill(image, img.getColor(255, 255, 255)); // พื้นหลังขาว

    /// Image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List imageBytesFromNetwork = response.bodyBytes;

    print("คิว:$queue");
    await initPlatformState();
    // แปลง queueDatetime เป็นวันที่ในรูปแบบ พ.ศ.
    DateTime parsedDate = DateTime.parse(queue.queueDatetime);
    int buddhistYear = parsedDate.year + 543;

    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    formattedDate = formattedDate.replaceFirst(
        parsedDate.year.toString(), buddhistYear.toString());
    String timeOnly = DateFormat('HH:mm').format(parsedDate);
    // ✅ แปลงข้อความเป็นรูปภาพ (รองรับภาษาไทย)
  Future<Uint8List> generateTextImage(String text) async {
    // ✅ โหลดฟอนต์ภาษาไทย (FreeSerif.ttf)
    ByteData fontData = await rootBundle.load("assets/fonts/FreeSerif.ttf");
    Uint8List fontBytes = fontData.buffer.asUint8List();

    // ✅ สร้างภาพพื้นหลังขาว ขนาด 400x100 px
    img.Image image = img.Image(400, 100);
    img.fill(image, img.getColor(255, 255, 255));

    // ✅ ใช้ฟอนต์ FreeSerif.ttf วาดข้อความ
    img.drawString(image, img.arial_24, 20, 20, text,
        color: img.getColor(0, 0, 0)); // สีดำ

    // ✅ แปลงเป็น PNG และส่งกลับ
    return Uint8List.fromList(img.encodePng(image));
  }
   
    late Uint8List resizedImageBytesAP;

    int width = 100;
    int height = 100;
    bluetooth.printImageBytes(resizedImageBytes);
    // bluetooth.printImageBytes(resizedImageBytesFF);

    bluetooth.printNewLine();
    bluetooth.printCustom("${queue.queueNo}", Size.extraLarge.val, Align.center.val);
    bluetooth.printNewLine();

    bluetooth.printCustom(
        "${queue.queueNumber} PAX", Size.boldMedium.val, Align.center.val);
    bluetooth.printNewLine();
      // ✅ วนลูปข้อมูล savedData และแปลงเป็นภาพก่อนพิมพ์
      for (var data in savedData) {
        String textToPrint = "";
        if (data['title'] != null && data['title']!.isNotEmpty) {
          textToPrint += "${data['title']}\n";
        }
        if (data['note1'] != null && data['note1']!.isNotEmpty) {
          textToPrint += "${data['note1']}\n";
        }
        if (data['note2'] != null && data['note2']!.isNotEmpty) {
          textToPrint += "${data['note2']}\n";
        }

        if (textToPrint.isNotEmpty) {
          Uint8List textImage = await generateTextImage(textToPrint);
          bluetooth.printImageBytes(textImage);
          bluetooth.printNewLine();
        }
      Uint8List imageData = Uint8List.fromList(img.encodePng(image));
      bluetooth.printImageBytes(imageData);
      print("✅ พิมพ์ข้อความภาษาไทยสำเร็จ!");

  
//     // วนลูปข้อมูลใน savedData และพิมพ์ออกมา
//    for (var data in savedData) {
//   print('✅Printing data:✅ $data'); // Debug เพื่อตรวจสอบข้อมูลก่อนพิมพ์

  
//   bluetooth.printCustom("${queue.queueNo}", Size.extraLarge.val, Align.center.val);
//   bluetooth.printNewLine();
//   bluetooth.printCustom("${queue.queueNumber} PAX", Size.bold.val, Align.center.val);
//   bluetooth.printNewLine();

//   // ✅ ตรวจสอบว่ามี title, note1 หรือ note2 หรือไม่
//   bool hasData = (data['title']?.isNotEmpty ?? false) ||
//                  (data['note1']?.isNotEmpty ?? false) ||
//                  (data['note2']?.isNotEmpty ?? false);

//   if (hasData) {
//     bluetooth.printCustom('${data['title'] ?? 'ไม่มีชื่อเรื่อง'}', Size.boldMedium.val, Align.center.val);
//     bluetooth.printNewLine();
//     bluetooth.printCustom('${data['note1'] ?? ''}', Size.bold.val, Align.center.val);
//     bluetooth.printCustom('${data['note2'] ?? ''}', Size.bold.val, Align.center.val);
//     bluetooth.printNewLine();
//   }else {
//     print("❌ ไม่มีข้อมูลใน title, note1 หรือ note2!");
//   }
// }

    bluetooth.printCustom(" $formattedDate", Size.bold.val, Align.center.val);
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.paperCut();
    print("Sample function completed");
  }
      }
}
