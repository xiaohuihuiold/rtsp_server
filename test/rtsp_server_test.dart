import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:rtsp_server/rtsp_server.dart';

void main() {
  test('server start', () async {
    final server = RTSPServer(port: 8554);
    server.start();
    await Future.delayed(const Duration(days: 1));
  }, timeout: const Timeout(Duration(days: 1)));

  test('byte data', () {
    final bytes = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final byteData = ByteData.view(bytes.buffer, 1, bytes.length - 1);
    print(bytes is List<int>);
    print(byteData.buffer.asUint8List(1, bytes.length - 1));
    print(byteData.offsetInBytes);
    print(byteData.lengthInBytes);
    print(1+( bytes.length - 1));
  });
}
