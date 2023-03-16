import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'logger.dart';

part 'rtsp_request.dart';

part 'rtsp_client.dart';

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
    logger.i('RTSP服务开启中...');
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
    logger.i('RTSP服务停止中...');
    _serverSocket?.close();
  }

  /// 服务停止
  void _onStop() {
    _running = false;
    logger.e('RTSP服务已停止');
  }

  /// 客户端连接
  void _onClientConnect(Socket socket) {
    final client = RTSPClient._create(socket: socket);
    logger.i('客户端连接', client: client);
    client.socket.listen(
      (bytes) => _onClientData(client, bytes),
      onDone: () => _onClientDisconnect(client),
    );
  }

  /// 客户端断开连接
  void _onClientDisconnect(RTSPClient client) {
    logger.i('客户端断开连接', client: client);
  }

  /// 客户端发送数据
  void _onClientData(RTSPClient client, Uint8List bytes) {
    if (client.state == RTSPClientState.none) {
      // 客户端未确定推流播流时只有文本数据
      try {
        final request = RTSPRequest._fromBytes(client, bytes);
        logger.v(
          '${request.method.method} ${request.uri.path}',
          client: request.client,
        );
      } catch (e) {
        logger.e('解析请求错误', client: client, error: e);
      }
    } else {
      // TODO: 处理RTP数据
    }
  }
}
