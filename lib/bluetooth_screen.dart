//  import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:hive/hive.dart';

// Future<void> initPlatformState() async {
//     bool? isConnected = await bluetooth.isConnected;
//     List<BluetoothDevice> devices = [];
//     try {
//       devices = await bluetooth.getBondedDevices();
//     } on PlatformException {}

//     var PrinterBox = await Hive.openBox('PrinterDevice');
//     String? savedAddress = PrinterBox.get('PrinterDevice');
//     await PrinterBox.close();

//     if (savedAddress != null) {
//       BluetoothDevice? savedDevice = devices.firstWhere(
//         (device) => device.address == savedAddress,
//       );

//       if (savedDevice != null) {
//         setState(() {
//           _device = savedDevice;
//           _messages.add("Connected to Device Printer");
//           _messages.add("Go to Main Screen");
//         });

//         bluetooth.connect(savedDevice).then((_) {
//           setState(() {
//             _connected = true;
//           });
//         }).catchError((error) {
//           setState(() {
//             _connected = false;
//           });
//         });
//       } else {
//         _messages.add("กรุณาไปหน้าตั้งค่าเพื่อทำการ เลือกเครื่องพิมพ์ก่อน");
//       }
//     }

//     bluetooth.onStateChanged().listen((state) {
//       switch (state) {
//         case BlueThermalPrinter.CONNECTED:
//           setState(() {
//             _connected = true;
//             print("bluetooth device state: connected");
//           });
//           break;
//         case BlueThermalPrinter.DISCONNECTED:
//           setState(() {
//             _connected = false;
//             print("bluetooth device state: disconnected");
//           });
//           break;
//         // Handle other states
//         default:
//           print(state);
//           break;
//       }
//     });

//     if (!mounted) return;
//     setState(() {
//       _devices = devices;
//     });

//     if (isConnected == true) {
//       setState(() {
//         _connected = true;
//       });
//     }
//   }
