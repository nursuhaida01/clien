// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';

// Future<void> generateThaiPdf() async {
//   final pdf = pw.Document();

//   // โหลดฟอนต์ไทยจาก assets
//   final fontData = await rootBundle.load('assets/fonts/Sarabun-Regular.ttf');
//   final ttf = pw.Font.ttf(fontData);

//   pdf.addPage(
//     pw.Page(
//       build: (pw.Context context) => pw.Center(
//         child: pw.Text(
//           'ใบเสร็จรับเงิน\nสวัสดี PDF!',
//           style: pw.TextStyle(font: ttf, fontSize: 20),
//         ),
//       ),
//     ),
//   );

//   // แสดงตัวอย่างก่อนพิมพ์
//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }
