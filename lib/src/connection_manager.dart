import 'dart:io';

import 'package:rtsp_server/src/logger.dart';

/// 连接管理器
class ConnectionManager {
  /// 端口
  final int port;

  /// socket
  ServerSocket? _serverSocket;

  /// 是否运行中
  bool _running = false;

  bool get running => _running;

  ConnectionManager(this.port);

  /// 开始
  Future<bool> start() async {
    logger.i('RTSP服务开启中......');
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket?.listen(
      _onClientConnect,
      onDone: _onStop,
    );
    _running = true;
    logger.i('RTSP服务已开启,端口:$port');
    return true;
  }

  /// 停止
  void stop() {
    logger.i('RTSP服务停止中......');
    _serverSocket?.close();
  }

  /// 服务停止
  void _onStop() {
    _running = false;
    logger.e('RTSP服务已停止');
  }

  /// 客户端连接
  void _onClientConnect(Socket client) {
    logger.i('客户端连接: ${client.remoteAddress.address}', socket: client);
    client.listen(
      (bytes) {},
      onDone: () {
        logger.i('客户端断开连接: ${client.remoteAddress.address}', socket: client);
      },
    );
  }
}
