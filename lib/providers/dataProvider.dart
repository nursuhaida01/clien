import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DataProvider with ChangeNotifier {
  // ตัวแปรสำหรับเก็บสถานะและข้อมูล
    String? _givenameValue;
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  String _connectionStatus = 'Not Connected';
  bool _isConnected = false;
  String? get givenameValue => _givenameValue;

  String get connectionStatus => _connectionStatus; // Getter สำหรับสถานะ
  bool get isConnected => _isConnected;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  BluetoothCharacteristic? get writeCharacteristic => _writeCharacteristic;

  get domainValue => null;

  // ฟังก์ชันสำหรับโหลดเครื่องพิมพ์จาก Hive
  Future<void> loadSavedPrinter() async {
    var printerBox = await Hive.openBox('PrinterDevice');
    String? savedPrinterId = printerBox.get('PrinterDevice');
    await printerBox.close();

    if (savedPrinterId != null) {
      _connectionStatus = 'Searching for saved printer...';
      notifyListeners();

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
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
