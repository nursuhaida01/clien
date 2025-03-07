import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';
import '../model/service_model.dart';

class QueueProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ตัวแปรสำหรับ Queue และ Service
  List<QueueModel> _queues = [];
  List<ServiceModel> _services = [];
  Map<int, int> _countWaitingByService = {}; // เก็บจำนวนคิวต่อ Service ID
 QueueModel? nextQueue; // ✅ เพิ่มตัวแปรเก็บคิวถัดไป

  String? _givenameValue;
 String? _givename58Value;
  String? _givename80Value;

  // ตัวแปรสำหรับ Printer
  
  String? _ipAddress;

  // Getters
  String? get givenameValue => _givenameValue;
  String? get givename58Value => _givename58Value;
  String? get givename80Value => _givename80Value;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  BluetoothCharacteristic? get writeCharacteristic => _writeCharacteristic;
  String? get ipAddress => _ipAddress;

  List<QueueModel> get queues => _queues;
  List<ServiceModel> get services => _services;
   Map<int, int> get countWaitingByService => _countWaitingByService;
   

   // ตัวแปรสำหรับเก็บสถานะและข้อมูล
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  String _connectionStatus = 'Not Connected';
  bool _isConnected = false;

  String get connectionStatus => _connectionStatus; // Getter สำหรับสถานะ
  bool get isConnected => _isConnected;
 
  get domainValue => null;


  // Setter for Givename Value
 
 Future<void> loadData() async {
    await _loadGiveNameData();
    await _loadGiveName58Data();
    await _loadGiveName80Data();
  }
  // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveName58Data() async {
    var GiveName58Box = await Hive.openBox('GiveName58Box');

    if (GiveName58Box.containsKey('GiveName58Box')) {
      _givename58Value = GiveName58Box.get('GiveName58Box');
    } else {
      _givename58Value = '';
      await GiveName58Box.put('GiveName58Box', _givename58Value);
    }

    notifyListeners();
  }
   // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveName80Data() async {
    var GiveName80Box = await Hive.openBox('GiveName80Box');

    if (GiveName80Box.containsKey('GiveName80Box')) {
      _givename80Value = GiveName80Box.get('GiveName80Box');
    } else {
      _givename80Value = '';
      await GiveName80Box.put('GiveName80Box', _givename80Value);
    }

    notifyListeners();
  }
    // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveName58Value(String value) async {
    var GiveName58Box = await Hive.openBox('GiveName58Box');
    _givename58Value = value;
    await GiveName58Box.put('GiveName58Box', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveName80Value(String value) async {
    var GiveName80Box = await Hive.openBox('GiveName80Box');
    _givename80Value = value;
    await GiveName80Box.put('GiveName80Box', value);
    notifyListeners();
  }
  // ------------------ reload Functions ------------------

 Future<void> setGiveNameValue(String value) async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');
    _givenameValue = value;
    await GiveNameBox.put('GiveNameBox', value);
    notifyListeners();
  }
    Future<void> _loadGiveNameData() async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');

    if (GiveNameBox.containsKey('GiveNameBox')) {
      _givenameValue = GiveNameBox.get('GiveNameBox');
    } else {
      _givenameValue = '';
      await GiveNameBox.put('GiveNameBox', _givenameValue);
    }

    notifyListeners();
  }
  

Future<void> reloadServices() async {
  try {
    clearQueues(); // ✅ เคลียร์ข้อมูลก่อนโหลดใหม่
     final dbHelper = DatabaseHelper.instance;
     _queues = await DatabaseHelper.instance.queryAll('queue_tb'); // โหลดข้อมูลใหม่
    await Future.delayed(Duration(milliseconds: 100)); // จำลองเวลาโหลด
    await fetchServices(); // เรียกฟังก์ชัน fetchServices แบบ asynchronous
     notifyListeners(); // ✅ ให้แจ้งเตือนที่นี่
  } catch (e) {
    print("Error reloading services: $e"); // จัดการข้อผิดพลาด
  }
}
void clearQueues() {
    _queues = []; // ✅ ลบข้อมูลใน List
    notifyListeners();
  }

  // ------------------ reload Functions ------------------


  // ------------------ Queue Functions ------------------
  Future<void> fetchQueues() async {
    _queues = await _dbHelper.queryAll('queue_tb');
    notifyListeners();
  }

Future<void> addQueue(QueueModel queue) async {
  int insertedId = await _dbHelper.insertQueue(queue);
  
  // สร้าง QueueModel ใหม่พร้อม id ที่ได้จากฐานข้อมูล
  QueueModel newQueue = QueueModel(
    id: insertedId, // ใช้ ID ที่เพิ่มเข้าไปในฐานข้อมูล
    queueNo: queue.queueNo,
    queueNumber: queue.queueNumber,
    customerName: queue.customerName,
    customerPhone: queue.customerPhone,
    queueStatus: queue.queueStatus,
    queueDatetime: queue.queueDatetime,
    queueCreate: queue.queueCreate,
    serviceId: queue.serviceId,
  );

  _queues.add(newQueue); // อัปเดตรายการคิวใน Provider โดยตรง
  notifyListeners(); // แจ้งให้ UI อัปเดตทันที
}



Future<void> updateQueue(QueueModel queue) async {
  await _dbHelper.updateQueue(queue);
  await fetchServices(); // โหลดข้อมูลบริการใหม่
  await fetchQueues(); // โหลดข้อมูลคิวใหม่
  notifyListeners(); //
}



  Future<void> deleteQueue(int id) async {
    await _dbHelper.deleteQueue(id);
    await fetchQueues();
  }

  // ------------------ Service Functions ------------------
 Future<void> fetchServices() async {
  try {
    final data = await DatabaseHelper.instance.queryAllServices();
    final queuesData = await DatabaseHelper.instance.queryAllQueues(); // โหลดคิวทั้งหมด

    _services = data;
    _queues = queuesData;

    // นับจำนวนคิวที่มีสถานะ "รอรับบริการ" แยกตาม Service ID
    final countMap = <int, int>{};
    for (var queue in _queues) {
      if (queue.queueStatus == 'รอรับบริการ') {
        countMap[queue.serviceId!] = (countMap[queue.serviceId!] ?? 0) + 1;
      }
    }
    _countWaitingByService = countMap;

    notifyListeners(); // 🚀 อัปเดต UI ให้โหลดข้อมูลใหม่
  } catch (e) {
    print('เกิดข้อผิดพลาดในการดึงข้อมูล Service: $e');
  }
}

 Future<void> clearAllServices() async {
    await DatabaseHelper.instance.clearAllServicesAndResetId();
    _services.clear(); // ล้างข้อมูลในแคช
    notifyListeners(); // แจ้งเตือน UI ว่าข้อมูลเปลี่ยนแปลง
  }
Future<void> addService(ServiceModel service) async {
  try {
    int insertedId = await DatabaseHelper.instance.insertService(service);
    ServiceModel updatedService = ServiceModel(
      id: insertedId, // อัปเดตค่า id ที่เพิ่งถูกสร้าง
      name: service.name,
      prefix: service.prefix,
      deletel: service.deletel,
    );

    _services.add(updatedService);
    notifyListeners(); // แจ้งให้ UI อัปเดตข้อมูล
  } catch (e) {
    print('เกิดข้อผิดพลาดในการเพิ่ม Service: $e');
  }
}


  Future<void> updateService(ServiceModel service) async {
    await _dbHelper.updateService(service);
    await fetchServices();
  }

  Future<void> deleteService(int id) async {
    await _dbHelper.deleteService(id);
    await fetchServices();
    
  }

  // ------------------ Printer Functions ------------------
  // ฟังก์ชันสำหรับพิมพ์ข้อมูล
  Future<void> printTicket(Uint8List data) async {
    if (_selectedDevice != null && _writeCharacteristic != null) {
      try {
        // ส่งข้อมูลไปยังเครื่องพิมพ์
        await _writeCharacteristic!.write(data);
        print('พิมพ์ข้อมูลสำเร็จ');
      } catch (e) {
        print('เกิดข้อผิดพลาดในการพิมพ์: $e');
      }
    } else {
      print('ยังไม่ได้ตั้งค่าเครื่องพิมพ์');
    }
  }

  // ฟังก์ชันสำหรับตั้งค่าเครื่องพิมพ์
  Future<void> setDevice(
      BluetoothDevice device, BluetoothCharacteristic characteristic, String ip) async {
    _selectedDevice = device;
    _writeCharacteristic = characteristic;
    _ipAddress = ip;

    // Save to Hive Box
    final box = await Hive.openBox('printerBox');
    await box.put('deviceName', device.name);
    await box.put('deviceId', device.id.toString());
    await box.put('ipAddress', ip);

    print('บันทึกเครื่องพิมพ์เรียบร้อย');
    notifyListeners();
  }

  // ฟังก์ชันโหลดการตั้งค่าจาก Hive
  Future<void> loadPrinterSettings() async {
    final box = await Hive.openBox('printerBox');
    final deviceName = box.get('deviceName');
    final deviceId = box.get('deviceId');
    final savedIpAddress = box.get('ipAddress');

    if (deviceName != null && deviceId != null) {
      _ipAddress = savedIpAddress;
      // ข้อมูล deviceId ต้องค้นหาอุปกรณ์อีกครั้งเพื่อโหลด BluetoothDevice และ Characteristic
      print('โหลดเครื่องพิมพ์ที่บันทึกไว้: $deviceName');
    } else {
      print('ยังไม่มีเครื่องพิมพ์ที่บันทึกใน Hive');
    }
    notifyListeners();
  }
  // ฟังก์ชันสำหรับโหลดเครื่องพิมพ์จาก Hive
  Future<void> loadSavedPrinter() async {
    var printerBox = await Hive.openBox('PrinterDevice');
    String? savedPrinterId = printerBox.get('PrinterDevice');
    await printerBox.close();

    if (savedPrinterId != null) {
      _connectionStatus = 'Searching for saved printer...';
      notifyListeners();

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));
      List<ScanResult> devices = [];
      FlutterBluePlus.scanResults.listen((results) {
        devices = results;
      });

      await Future.delayed(const Duration(seconds: 5));
      FlutterBluePlus.stopScan();

      for (var device in devices) {
        if (device.device.id.id == savedPrinterId) {
          _selectedDevice = device.device;
          _connectionStatus = 'Loaded Saved Printer: ${_selectedDevice!.name}';
          notifyListeners();
          break;
        }
      }

      if (_selectedDevice == null) {
        _connectionStatus = 'Saved printer not found. Please select again.';
        notifyListeners();
      }
    }
  }

  // ฟังก์ชันสำหรับเชื่อมต่ออุปกรณ์
  Future<void> connectDevice() async {
    if (_selectedDevice == null) {
      _connectionStatus = 'No device selected.';
      notifyListeners();
      return;
    }

    try {
      _connectionStatus = 'Connecting to ${_selectedDevice!.name}...';
      notifyListeners();

      await _selectedDevice!.connect(timeout: const Duration(seconds: 10));
      _isConnected = true;
      _connectionStatus = 'Connected to ${_selectedDevice!.name}';
      notifyListeners();

      // Discover writable characteristic
      List<BluetoothService> services =
          await _selectedDevice!.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            notifyListeners();
            break;
          }
        }
      }

      if (_writeCharacteristic == null) {
        _connectionStatus = 'No writable characteristic found.';
        notifyListeners();
      }

      // Save the printer address in Hive
      var printerBox = await Hive.openBox('PrinterDevice');
      await printerBox.put('PrinterDevice', _selectedDevice!.id.id);
      await printerBox.close();
    } catch (e) {
      _connectionStatus = 'Failed to connect: $e';
      notifyListeners();
    }
  }

  // ฟังก์ชันสำหรับตัดการเชื่อมต่อ
  Future<void> disconnectDevice() async {
    if (_selectedDevice == null) {
      _connectionStatus = 'No device connected.';
      notifyListeners();
      return;
    }

    try {
      await _selectedDevice!.disconnect();
      _isConnected = false;
      _connectionStatus = 'Disconnected from ${_selectedDevice!.name}';
      notifyListeners();

      // Remove the printer address from Hive
      var printerBox = await Hive.openBox('PrinterDevice');
      await printerBox.delete('PrinterDevice');
      await printerBox.close();
    } catch (e) {
      _connectionStatus = 'Failed to disconnect: $e';
      notifyListeners();
    }
  }

  // ฟังก์ชันสำหรับสแกนหาอุปกรณ์ใหม่
  Future<void> scanDevices() async {
    _connectionStatus = 'Scanning for devices...';
    notifyListeners();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    List<ScanResult> devices = [];

    FlutterBluePlus.scanResults.listen((results) {
      devices = results;
    });

    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();

    if (devices.isNotEmpty) {
      _connectionStatus = 'Scan complete. Select a device to connect.';
    } else {
      _connectionStatus = 'No devices found.';
    }

    notifyListeners();
  }

}
