import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:rtsp_server/src/rtsp_headers.dart';

import 'logger.dart';

part 'rtsp_request.dart';

part 'rtsp_response.dart';

part 'rtsp_client.dart';

typedef HandleCallback = void Function(RTSPRequest);

/// 请求处理
class RequestHandler {
  final _handles = <RTSPRequestMethod, HandleCallback>{};

  RequestHandler._();

  /// 添加请求处理
  void handle(RTSPRequestMethod method, HandleCallback callback) {
    _handles[method] = callback;
  }

  /// 移除请求处理
  void removeHandle(RTSPRequestMethod method) {
    _handles.remove(method);
  }

  void describe(HandleCallback callback) {
    handle(RTSPRequestMethod.describe, callback);
  }

  void announce(HandleCallback callback) {
    handle(RTSPRequestMethod.announce, callback);
  }

  void options(HandleCallback callback) {
    handle(RTSPRequestMethod.options, callback);
  }

  void play(HandleCallback callback) {
    handle(RTSPRequestMethod.play, callback);
  }

  void record(HandleCallback callback) {
    handle(RTSPRequestMethod.record, callback);
  }

  void setup(HandleCallback callback) {
    handle(RTSPRequestMethod.setup, callback);
  }

  void teardown(HandleCallback callback) {
    handle(RTSPRequestMethod.teardown, callback);
  }

  HandleCallback? operator [](RTSPRequestMethod method) {
    return _handles[method];
  }
}

/// 连接管理器
class ConnectionManager {
  /// 端口
  final int port;

  /// 服务器名称
  final String serverName;

  /// socket
  ServerSocket? _serverSocket;

  /// 请求处理
  final handler = RequestHandler._();

  /// 是否运行中
  bool _running = false;

  bool get running => _running;

  ConnectionManager({
    required this.port,
    required this.serverName,
  });

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
    final client = RTSPClient._create(this, socket: socket);
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
          '请求${request.method.method} ${request.path}',
          client: request.client,
        );
        final handle = handler[request.method];
        if (handle != null) {
          try {
            handle(request);
          } catch (e) {
            logger.e('请求处理错误', client: client, error: e);
            request.sendResponse(
                RTSPResponse.internalServerError(body: e.toString()));
          }
        } else {
          request.sendResponse(RTSPResponse.methodNotAllowed());
        }
      } catch (e) {
        logger.e('解析请求错误', client: client, error: e);
        client.send(RTSPResponse.badRequest().toResponseText());
      }
    } else {
      // TODO: 处理RTP数据
    }
  }
}
