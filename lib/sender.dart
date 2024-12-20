import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'print/testprint.dart';
// Import the TestPrint class

class SenderApp extends StatefulWidget {
  @override
  _SenderAppState createState() => _SenderAppState();
}

class _SenderAppState extends State<SenderApp> {
  final flutterBlue = FlutterBluePlus();
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  String connectionStatus = 'Not Connected';
  bool isConnected = false;
  final TestPrint testPrint = TestPrint(); // Create an instance of TestPrint

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Request Bluetooth permissions
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      appBar: AppBar(
        title: const Text(
          'เลือกเครื่องพิมพ์',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: connectionStatus),
              decoration: InputDecoration(
                labelText: 'Connection Status',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  onPressed: scanDevices,
                  child: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected ? Colors.red : Colors.green,
                  ),
                  onPressed: selectedDevice != null
                      ? (isConnected ? disconnectDevice : connectDevice)
                      : null,
                  child: Text(
                    isConnected ? 'Disconnect' : 'Connect',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () {
                  if (selectedDevice != null && writeCharacteristic != null) {
                    TestPrint().sample(writeCharacteristic);
                  } else {
                    print('No device or characteristic selected.');
                  }
                },
                child: const Text(
                  'PRINT TEST',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scanDevices() async {
    setState(() {
      connectionStatus = 'Scanning for devices...';
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    List<ScanResult> devices = [];

    FlutterBluePlus.scanResults.listen((results) {
      devices = results;
    });

    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();

    if (devices.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select a Device'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(devices[index].device.name.isNotEmpty
                        ? devices[index].device.name
                        : 'Unknown Device'),
                    subtitle: Text(devices[index].device.id.toString()),
                    onTap: () {
                      Navigator.pop(context);
                      selectedDevice = devices[index].device;
                      setState(() {
                        connectionStatus = 'Selected: ${selectedDevice!.name}';
                      });
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } else {
      setState(() {
        connectionStatus = 'No devices found.';
      });
    }
  }

  void connectDevice() async {
    if (selectedDevice == null) {
      setState(() {
        connectionStatus = 'No device selected.';
      });
      return;
    }

    try {
      setState(() {
        connectionStatus = 'Connecting to ${selectedDevice!.name}...';
      });

      await selectedDevice!.connect(timeout: const Duration(seconds: 10));
      setState(() {
        connectionStatus = 'Connected to ${selectedDevice!.name}';
        isConnected = true;
      });

      // Discover writable characteristic
      List<BluetoothService> services =
          await selectedDevice!.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            writeCharacteristic = characteristic;
            break;
          }
        }
      }

      if (writeCharacteristic == null) {
        setState(() {
          connectionStatus = 'No writable characteristic found.';
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = 'Failed to connect: $e';
      });
    }
  }

  void disconnectDevice() async {
    if (selectedDevice == null) {
      setState(() {
        connectionStatus = 'No device connected.';
      });
      return;
    }

    try {
      await selectedDevice!.disconnect();
      setState(() {
        connectionStatus = 'Disconnected from ${selectedDevice!.name}';
        isConnected = false;
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Failed to disconnect: $e';
      });
    }
  }

  void printTestMessage() async {
    if (writeCharacteristic == null) {
      setState(() {
        connectionStatus = 'No writable characteristic found.';
      });
      return;
    }

    try {
      final message =
          'Test Print Message\nThank you for using our service.\n\n';
      await writeCharacteristic!.write(Uint8List.fromList(message.codeUnits));
      setState(() {
        connectionStatus = 'Message sent successfully.';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Failed to send message: $e';
      });
    }
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SenderApp(),
  ));
}
