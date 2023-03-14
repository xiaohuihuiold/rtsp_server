import 'package:flutter_test/flutter_test.dart';

import 'package:rtsp_server/rtsp_server.dart';

void main() {
  test('server start', () async {
    final server = RTSPServer(port: 8554);
    server.start();
    await Future.delayed(const Duration(days: 1));
  }, timeout: const Timeout(Duration(days: 1)));
}
