import 'dart:convert';
import 'dart:typed_data';
import 'package:client/providers/queue_provider.dart';
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
import '../providers/dataProvider.dart';
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

  Future<void> printSingleImage(String fileName,
      {int? targetWidth, int? targetHeight}) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/$fileName';
      File savedImageFile = File(filePath);

      if (await savedImageFile.exists()) {
        Uint8List imageBytes = await savedImageFile.readAsBytes();

        // ✅ แปลงข้อมูลภาพเป็น Object เพื่อปรับขนาด
        img.Image? originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          // ✅ ถ้าไม่กำหนดขนาด จะใช้ขนาดเดิมของรูป
          int width = targetWidth ?? originalImage.width;
          int height = targetHeight ?? originalImage.height;

          // ✅ ปรับขนาดภาพ
          img.Image resizedImage =
              img.copyResize(originalImage, width: width, height: height);

          // ✅ สร้าง Canvas ใหม่เพื่อจัดตำแหน่งให้อยู่ตรงกลาง (สมมติว่าความกว้างของกระดาษคือ 576px)
          int paperWidth = 384; // ความกว้างมาตรฐานสำหรับเครื่องพิมพ์ใบเสร็จ
          int padding = ((paperWidth - width) / 2)
              .round(); // คำนวณ Padding ให้อยู่กึ่งกลาง

          // ✅ สร้างภาพพื้นหลังสีขาว
          img.Image centeredImage = img.Image(paperWidth, height);
          img.fill(centeredImage, img.getColor(255, 255, 255)); // สีพื้นหลังขาว

          // ✅ วางภาพให้อยู่ตรงกลาง
          img.copyInto(centeredImage, resizedImage, dstX: padding, dstY: 0);

          // ✅ แปลงกลับเป็น Bytes สำหรับการพิมพ์
          Uint8List finalImageBytes =
              Uint8List.fromList(img.encodePng(centeredImage));

          // ✅ ส่งภาพไปเครื่องพิมพ์
          bluetooth.printImageBytes(finalImageBytes);

          print("✅ พิมพ์รูปภาพสำเร็จ: $fileName (ขนาด: ${width}x${height} px)");
        } else {
          print("❌ ไม่สามารถแปลงไฟล์เป็นรูปภาพได้: $fileName");
        }
      } else {
        print("❌ ไม่พบไฟล์: $filePath");
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการพิมพ์รูป: $e");
    }
  }

  Future<void> sample(BuildContext context, dynamic queue,
      List<Map<String, String>> savedData) async {
    await initPlatformState();

    final hiveData = Provider.of<QueueProvider>(context, listen: false);

    if (hiveData.givename58Value == 'Checked') {
      String filename = 'logoap.png';
      ByteData bytesData = await rootBundle.load("assets/logo/logoap.png");
      String dir = (await getApplicationDocumentsDirectory()).path;
      await File('$dir/$filename').writeAsBytes(bytesData.buffer
          .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

      // โหลดรูปภาพโลโก้
      ByteData bytesAsset = await rootBundle.load("assets/logo/logoap.png");
      Uint8List imageBytesFromAsset = bytesAsset.buffer
          .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

      ByteData fontData =
          await rootBundle.load('assets/fonts/THSarabunNew.ttf');
      Uint8List fontBytes = fontData.buffer.asUint8List();

      DateTime parsedDate = DateTime.parse(queue.queueDatetime);
      int buddhistYear = parsedDate.year + 543;
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      formattedDate = formattedDate.replaceFirst(
          parsedDate.year.toString(), buddhistYear.toString());

      // ปรับขนาดรูปภาพ
      img.Image? image = img.decodeImage(imageBytesFromAsset);
      img.Image resizedImage = img.copyResize(image!, width: 271, height: 152);
      Uint8List resizedImageBytes =
          Uint8List.fromList(img.encodeJpg(resizedImage));
      Uint8List imageBytes = Uint8List.fromList(img.encodePng(image));

      print("คิว: $queue");
      if (_connected) {
        int width = 100;
        int height = 100;
        bluetooth.printImageBytes(resizedImageBytes);
        // await printSingleImage('savedData_line1_1.png',
        //     targetWidth: 250, targetHeight: 60);
         await printSingleImage('savedData_line1_1.png');
        bluetooth.printNewLine();
        bluetooth.printCustom("${queue.queueNo}",
            Size.extraLarge.val, Align.center.val);
        bluetooth.printNewLine();
        await printSingleImage('savedData_line2_1.png');
        await printSingleImage('savedData_line3_1.png');
        bluetooth.printNewLine();
        bluetooth.printCustom(
            " $formattedDate", Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth.paperCut();
        print("Printing completed.");
      } else {
        print("Bluetooth is not connected.");
      }
    } else if (hiveData.givename80Value == 'Checked') {
      String filename = 'logoap.png';
      ByteData bytesData = await rootBundle.load("assets/logo/logoap.png");
      String dir = (await getApplicationDocumentsDirectory()).path;
      await File('$dir/$filename').writeAsBytes(bytesData.buffer
          .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

      // โหลดรูปภาพโลโก้
      ByteData bytesAsset = await rootBundle.load("assets/logo/logoap.png");
      Uint8List imageBytesFromAsset = bytesAsset.buffer
          .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

      ByteData fontData =
          await rootBundle.load('assets/fonts/THSarabunNew.ttf');
      Uint8List fontBytes = fontData.buffer.asUint8List();

      DateTime parsedDate = DateTime.parse(queue.queueDatetime);
      int buddhistYear = parsedDate.year + 543;
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      formattedDate = formattedDate.replaceFirst(
          parsedDate.year.toString(), buddhistYear.toString());

      // ปรับขนาดรูปภาพ
      img.Image? image = img.decodeImage(imageBytesFromAsset);
      img.Image resizedImage = img.copyResize(image!, width: 271, height: 152);
      Uint8List resizedImageBytes =
          Uint8List.fromList(img.encodeJpg(resizedImage));
      Uint8List imageBytes = Uint8List.fromList(img.encodePng(image));

      print("คิว: $queue");
      if (_connected) {
        int width = 100;
        int height = 100;
        bluetooth.printImageBytes(resizedImageBytes);
        await printSingleImage('savedData_line1_1.png');
        bluetooth.printNewLine();
        bluetooth.printCustom("\x1D\x21\x22${queue.queueNo}",
            Size.extraLarge.val, Align.center.val);
        bluetooth.printNewLine();
        await printSingleImage('savedData_line2_1.png');
        await printSingleImage('savedData_line3_1.png');

        print("No data found in savedData.");
        bluetooth.printCustom(
            " $formattedDate", Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth.paperCut();
        print("Printing completed.");
      }
    }
  }
}
