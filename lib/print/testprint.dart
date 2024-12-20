import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TestPrint {
  Future<void> sample(BluetoothCharacteristic? writeCharacteristic) async {
    if (writeCharacteristic == null) {
      print('No writable characteristic found.');
      return;
    }
    try {
      final message = 'Test Print Message\nThank you for using our service.\n\n';
      await writeCharacteristic.write(Uint8List.fromList(message.codeUnits));
      print('Message sent successfully.'); // This will only print to console, not update UI.
    } catch (e) {
      print('Failed to send message: $e');
    }
  }
}
