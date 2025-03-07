import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'client.dart';
import 'providers/dataProvider.dart';
import 'providers/queue_provider.dart';
import 'home_page.dart';

void main() async {
  
  
  WidgetsFlutterBinding.ensureInitialized();
//  sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;

  await Hive.initFlutter();
  await Hive.openBox('savedDataBox');
  await Hive.openBox('ipBox'); // เปิดกล่องสำหรับเก็บ IP

 // Initialize Hive
 
    runApp(
    ChangeNotifierProvider(
      create: (_) => QueueProvider(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()..loadSavedPrinter()),
     
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MainPageScreen(),
      ),
    );
  }
}

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({Key? key}) : super(key: key);

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
    late ClientModel clientModel;
  List<String> _messages = ["กำลังตรวจสอบสถานะ Bluetooth..."];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // checkIpConnectionStatus();  // ตรวจสอบการเชื่อมต่อ IP
    // Delay ก่อนเปลี่ยนไปยังหน้าหลัก
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'AP Queue')),
      );
    });
     
  }
//   Future<void> checkIpConnectionStatus() async {
//   try {
//     // ดึง IP ที่บันทึกไว้ใน Hive
//     var box = await Hive.openBox('ipBox');
//     String? savedIP = box.get('savedIP');

//     if (savedIP != null) {
//       // แสดงข้อความว่ากำลังตรวจสอบ IP
//       setState(() {
//         _messages.add("🔍 กำลังตรวจสอบการเชื่อมต่อกับ IP: $savedIP");
//       });

//       // จำลองการเชื่อมต่อกับ IP (ในที่นี้ใช้ Delay เพื่อจำลอง)
//       await Future.delayed(const Duration(seconds: 2));

//       // ตรวจสอบว่า IP นี้ยังเชื่อมต่อได้หรือไม่ (สมมติว่าเชื่อมต่อสำเร็จ)
//       setState(() {
//         _messages.add("✅ เชื่อมต่อกับ IP: $savedIP สำเร็จ");
//       });
//     } else {
//       setState(() {
//         _messages.add("⚠️ ไม่พบ IP ที่บันทึกไว้ กรุณาเชื่อมต่อใหม่");
//       });
//     }
//   } catch (e) {
//     setState(() {
//       _messages.add("❌ เกิดข้อผิดพลาดในการตรวจสอบ IP: $e");
//     });
//   }
// }


  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (e) {
      print("Error fetching bonded devices: $e");
    }

    var printerBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = printerBox.get('PrinterDevice');
    await printerBox.close();

    if (savedAddress != null) {
      BluetoothDevice? savedDevice = devices.firstWhere(
        (device) => device.address == savedAddress,
      );

      if (savedDevice != null) {
        setState(() {
          _device = savedDevice;
          _messages.add("Connected to Device Printer: ${savedDevice.name}");
        });

        bluetooth.connect(savedDevice).then((_) {
          setState(() {
            _connected = true;
          });
        }).catchError((error) {
          setState(() {
            _connected = false;
          });
          print("Error connecting to device: $error");
        });
      } else {
        setState(() {
          _messages.add("กรุณาไปหน้าตั้งค่าเพื่อทำการเลือกเครื่องพิมพ์");
        });
      }
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _messages.add("Bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _messages.add("Bluetooth device state: disconnected");
          });
          break;
        default:
          print("Bluetooth state: $state");
          break;
      }
    });

    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.01;
    final buttonWidth = size.width * 0.01;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromRGBO(9, 159, 175, 1.0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo/images.png', // Replace with your logo's path
                width: screenSize.width,
                height: screenSize.width,
              ),
              const SizedBox(height:20), // Space between logo and CircularProgressIndicator
              const CircularProgressIndicator(),
              const SizedBox(height: 20), // Space between loader and messages
              ..._messages.map((msg) => Text(
                    msg,
                    textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.white,  fontSize: 20),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
