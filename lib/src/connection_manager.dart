import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:rtsp_server/src/rtp_packet.dart';
import 'package:rtsp_server/src/rtsp_headers.dart';
import 'package:synchronized/synchronized.dart';
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
typedef OnRTP = void Function(RTSPSession, Uint8List);

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

  /// RTP回调
  final OnRTP _onRTP;

  /// 请求处理
  final handler = RequestHandler._();

  /// 分包的请求
  final _idleRequest = <RTSPSession, RTSPRequest>{};

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
    required OnRTP onRTP,
  })  : _onSessionConnected = onSessionConnected,
        _onSessionDisconnected = onSessionDisconnected,
        _onRTP = onRTP;

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
    /*if (bytes[0] != 0x24 || session.state == RTSPSessionState.none) {
      // 客户端未确定推流播流时只有文本数据
      _handleRequest(session, bytes);
    } else {
      _handleRTP(session, bytes);
    }*/
    // 0x24表示RTP数据

    if (bytes[0] == 0x24) {
      int offset = 0;
      while (offset < bytes.length) {
        offset += 1;
        final isRTCP = bytes[offset] & 0x1 == 1;
        offset += 2;
        final length = (bytes[offset - 1] << 8) | bytes[offset];
        offset += 1;
        if (offset + length > bytes.length) {
          logger.w('不完整的包', session: session);
          break;
        }
        final byteData = ByteData.view(bytes.buffer, offset, length);
        offset += length;
        if (isRTCP) {
          // TODO:处理RTCP
        } else {
          _handleRTP(session, byteData);
        }
      }
    } else {
      _handleRequest(session, bytes);
    }
  }

  /// 处理请求
  void _handleRequest(RTSPSession session, Uint8List bytes) {
    try {
      final data = utf8.decode(bytes);
      final partRequest = _idleRequest.remove(session);
      if (partRequest != null) {
        partRequest.setBody(data);
        logger.v('请求分包合并', session: session);
      }

      final cSeqReg = RegExp(r'CSeq\s*:\s*(\d+)');
      final cSeqMatch = cSeqReg.firstMatch(data);
      final cSeq = cSeqMatch?.group(1) ?? partRequest?.cSeq;
      try {
        final request = partRequest ??
            RTSPRequest._fromString(
              session,
              data: data,
              serverName: serverName,
            );
        logger.v(
          '请求${request.method.method} ${request.path}',
          session: request.session,
        );
        final contentLength =
            int.tryParse(request.getHeader(RTSPHeaders.contentLength) ?? '');
        if (contentLength != null &&
            contentLength != 0 &&
            request.body?.isNotEmpty != true) {
          logger.v('请求分包', session: request.session);
          _idleRequest[session] = request;
          return;
        }
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
  }

  /// 处理RTP数据
  void _handleRTP(RTSPSession session, ByteData byteData) {
    final version = byteData.getUint8(0) >> 6;
    final padding = (byteData.getUint8(0) >> 5) & 0x1;
    final extension = (byteData.getUint8(0) >> 4) & 0x1;
    final csrcLength = byteData.getUint8(0) & 0xf;

    final marker = (byteData.getUint8(1) >> 7) & 0x1;
    final payloadType = byteData.getUint8(1) & 0x71;
    final seq = (byteData.getUint8(2) << 8) | byteData.getUint8(3);
    final timestamp = (byteData.getUint8(4) << 24) |
        (byteData.getUint8(5) << 16) |
        (byteData.getUint8(6) << 8) |
        byteData.getUint8(7);
    final ssrc = (byteData.getUint8(8) << 24) |
        (byteData.getUint8(9) << 16) |
        (byteData.getUint8(10) << 8) |
        byteData.getUint8(11);
    final csrc = <int>[];
    for (int i = 0; i < csrcLength; i++) {
      csrc.add((byteData.getUint8(12 + i) << 24) |
          (byteData.getUint8(13 + i) << 16) |
          (byteData.getUint8(14 + i) << 8) |
          byteData.getUint8(15 + i));
    }
    final rtpPacket = RTPPacket(
      version: version,
      padding: padding,
      extension: extension,
      csrcLength: csrcLength,
      marker: marker,
      payloadType: payloadType,
      seq: seq,
      timestamp: timestamp,
      ssrc: ssrc,
      csrc: csrc,
      payload: byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    // print(rtpPacket);
    if (rtpPacket.payloadType == RTPPayloadType.h264) {
      _onRTP(session, rtpPacket.toBytes());
    }
  }
}
