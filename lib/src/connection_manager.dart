import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:rtsp_server/src/rtsp_headers.dart';
import 'package:uuid/uuid.dart';

import 'exceptions.dart';
import 'logger.dart';

part 'rtsp_request.dart';

part 'rtsp_response.dart';

part 'rtsp_session.dart';

part 'sessions_manager.dart';

typedef HandleCallback = void Function(RTSPRequest);
typedef OnSessionConnected = void Function(RTSPSession);
typedef OnSessionDisconnected = void Function(RTSPSession);

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

  /// 会话连接
  final OnSessionConnected _onSessionConnected;

  /// 会话断开
  final OnSessionDisconnected _onSessionDisconnected;

  /// 请求处理
  final handler = RequestHandler._();

  /// socket
  ServerSocket? _serverSocket;

  /// 是否运行中
  bool _running = false;

  bool get running => _running;

  ConnectionManager({
    required this.port,
    required this.serverName,
    required OnSessionConnected onSessionConnected,
    required OnSessionDisconnected onSessionDisconnected,
  })  : _onSessionConnected = onSessionConnected,
        _onSessionDisconnected = onSessionDisconnected;

  /// 开始
  Future<bool> start() async {
    logger.i('RTSP服务开启中...');
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket?.listen(
      _onClientConnected,
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
  void _onClientConnected(Socket socket) {
    final session = RTSPSession._create(
      serverName: serverName,
      socket: socket,
    );
    logger.i('客户端连接', session: session);
    _onSessionConnected(session);
    session._listen(
      (bytes) => _onClientData(session, bytes),
      onDone: () => _onClientDisconnected(session),
      onError: (e) => logger.e('客户端异常', session: session, error: e),
    );
  }

  /// 客户端断开连接
  void _onClientDisconnected(RTSPSession session) {
    logger.i('客户端断开连接', session: session);
    session._state = RTSPSessionState.disconnected;
    _onSessionDisconnected(session);
  }

  /// 客户端发送数据
  void _onClientData(RTSPSession session, Uint8List bytes) {
    if (session.state == RTSPSessionState.none) {
      // 客户端未确定推流播流时只有文本数据
      try {
        final data = utf8.decode(bytes);

        final cSeqReg = RegExp(r'CSeq\s*:\s*(\d+)');
        final cSeqMatch = cSeqReg.firstMatch(data);
        final cSeq = cSeqMatch?.group(1);
        try {
          final request = RTSPRequest._fromString(
            session,
            data: data,
            serverName: serverName,
          );
          logger.v(
            '请求${request.method.method} ${request.path}',
            session: request.session,
          );
          final handle = handler[request.method];
          if (handle != null) {
            try {
              handle(request);
            } catch (e) {
              logger.e('请求处理错误', session: session, error: e);
              request.sendResponse(
                RTSPResponse.internalServerError(body: e.toString()),
              );
            }
          } else {
            request.sendResponse(RTSPResponse.methodNotAllowed());
          }
        } on RequestMethodException catch (e) {
          final response = RTSPResponse.methodNotAllowed();
          response.cSeq = cSeq;
          logger.w('不支持的方法', session: session, error: e);
          session.sendResponse(response);
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        logger.e('解析请求错误', session: session, error: e);
        session.sendResponse(RTSPResponse.badRequest(body: e.toString()));
      }
    } else {
      // TODO: 处理RTP数据
    }
  }
}
