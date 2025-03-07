import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'printerenum.dart';

class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
// ✅ แปลงข้อความเป็น TIS-620
  Future<void> printSingleImage(String fileName) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/$fileName';
      File savedImageFile = File(filePath);

      if (await savedImageFile.exists()) {
        Uint8List imageBytes = await savedImageFile.readAsBytes();

        // ✅ แปลงข้อมูลภาพเป็น Object เพื่อดึงขนาดจริง
        img.Image? originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          // ✅ ดึงขนาดจริงของรูปภาพ
          int imageWidth = originalImage.width;
          int imageHeight = originalImage.height;

          print("📏 ขนาดภาพ: $imageWidth x $imageHeight px");

          // ✅ สร้าง Canvas ใหม่เพื่อจัดตำแหน่งให้อยู่ตรงกลาง (สมมติว่าความกว้างของกระดาษคือ 576px)
          int paperWidth = 384; // ความกว้างมาตรฐานของเครื่องพิมพ์ใบเสร็จ
          int padding = ((paperWidth - imageWidth) / 2)
              .round(); // คำนวณ Padding ให้อยู่กึ่งกลาง

          // ✅ สร้างภาพพื้นหลังสีขาว
          img.Image centeredImage = img.Image(paperWidth, imageHeight);
          img.fill(centeredImage, img.getColor(255, 255, 255)); // สีพื้นหลังขาว

          // ✅ วางภาพที่ดึงมาลงบนพื้นหลังให้อยู่กึ่งกลาง
          img.copyInto(centeredImage, originalImage, dstX: padding, dstY: 0);

          // ✅ แปลงกลับเป็น Bytes สำหรับการพิมพ์
          Uint8List finalImageBytes =
              Uint8List.fromList(img.encodePng(centeredImage));

          // ✅ ส่งภาพไปเครื่องพิมพ์
          bluetooth.printImageBytes(finalImageBytes);

          print("✅ พิมพ์รูปภาพสำเร็จ: $fileName (ขนาดจริงและอยู่กึ่งกลาง)");
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

  Future<void> sample(List<Map<String, String>> savedData) async {

     // เรียกใช้งาน Hive Box
  final Box imagesBox = await Hive.openBox('imagesBox');
  
    print("Starting sample function");
    String filename = 'logoap.png';

    ByteData bytesData = await rootBundle.load("assets/logo/logoap.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));
    ByteData bytesAsset = await rootBundle.load("assets/logo/logoap.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    // Resize the image
    img.Image? image = img.decodeImage(imageBytesFromAsset);
    img.Image resizedImage = img.copyResize(image!, width: 300, height: 170);
    Uint8List resizedImageBytes =
        Uint8List.fromList(img.encodeJpg(resizedImage));

    // font1
    ByteData bytesAssetFF = await rootBundle.load("assets/logo/font2.jpg");
    Uint8List imageBytesFromAssetFF = bytesAssetFF.buffer
        .asUint8List(bytesAssetFF.offsetInBytes, bytesAssetFF.lengthInBytes);

    img.Image? imageFF = img.decodeImage(imageBytesFromAssetFF);
    img.Image resizedImageFF =
        img.copyResize(imageFF!, width: 400, height: 100);
    Uint8List resizedImageBytesFF =
        Uint8List.fromList(img.encodeJpg(resizedImageFF));

    /// Image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List imageBytesFromNetwork = response.bodyBytes;

    bluetooth.isConnected.then((isConnected) async {
      if (isConnected == true) {
        print("Bluetooth is connected");
        int width = 100;
        int height = 100;
        bluetooth.printImageBytes(resizedImageBytes);
        // ✅ พิมพ์ภาพแบบจัดกึ่งกลาง (ขนาด 300x150)
        await printSingleImage('savedData_line1_1.png');
           bluetooth.printCustom("A001",
            Size.extraLarge.val, Align.center.val);
     
        await printSingleImage('savedData_line2_1.png');
        await printSingleImage('savedData_line3_1.png');
           bluetooth.printNewLine();
        bluetooth.printCustom("5/3/2568",
            Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); // Some printers not supported (sometime making image not centered)
        print("Finished printing image from asset");
      } else {
        print("Bluetooth is not connected");
      }
    }).catchError((error) {
      print("Error checking Bluetooth connection: $error");
    });

    print("Sample function completed");
  }
}
