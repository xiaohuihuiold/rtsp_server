import 'dart:typed_data';

import 'package:rtsp_server/src/logger.dart';
import 'package:rtsp_server/src/streams_manager.dart';

import 'rtsp_headers.dart';
import 'connection_manager.dart';

/// rtsp服务
class RTSPServer {
  /// 端口
  final int port;

  /// 名称
  final String serverName;

  /// 连接管理器
  ConnectionManager? _connectionManager;

  /// 会话管理器
  final sessionsManager = SessionsManager();

  /// 流管理器
  final streamsManager = StreamsManager();

  RTSPServer({
    required this.port,
    this.serverName = 'rtspserver',
  });

  /// 开启服务
  Future<bool> start() async {
    if (_connectionManager?.running == true) {
      return true;
    }
    _connectionManager?.stop();
    _connectionManager = ConnectionManager(
      port: port,
      serverName: serverName,
      onSessionConnected: _onSessionConnected,
      onSessionDisconnected: _onSessionDisconnected,
      onRTP: _onRTP,
    );
    _connectionManager?.handler.describe(_handleDescribe);
    _connectionManager?.handler.announce(_handleAnnounce);
    _connectionManager?.handler.options(_handleOptions);
    _connectionManager?.handler.play(_handlePlay);
    _connectionManager?.handler.record(_handleRecord);
    _connectionManager?.handler.setup(_handleSetup);
    _connectionManager?.handler.teardown(_handleTeardown);
    return await _connectionManager?.start() == true;
  }

  /// 停止服务
  void stop() {
    _connectionManager?.stop();
  }

  void _onSessionConnected(RTSPSession session) {
    sessionsManager.addSession(session);
  }

  void _onSessionDisconnected(RTSPSession session) {
    sessionsManager.removeSession(session);
    final streams = streamsManager.getStreams(session.path);
    if (streams != null) {
      if (streams.recorder == session) {
        streamsManager.destroyStreams(streams);
      } else {
        streams.removePlayer(session);
      }
    }
  }

  void _handleDescribe(RTSPRequest request) {
    final streams = streamsManager.getStreams(request.session.path);
    if (streams == null) {
      request.sendResponse(RTSPResponse.notFound());
    } else {
      sessionsManager.setSessionRole(request.session, RTSPSessionRole.player);
      request.sendResponse(RTSPResponse.describe(
        sdp: streams.sdp,
        baseUrl: request.path,
      ));
    }
  }

  void _handleAnnounce(RTSPRequest request) {
    final sdp = request.body;
    if (sdp == null) {
      request.sendResponse(RTSPResponse.badRequest(body: 'sdp=null'));
    } else {
      logger.v('设置sdp数据: \n$sdp', session: request.session);
      sessionsManager.setSessionRole(request.session, RTSPSessionRole.recorder);
      final streams = streamsManager.spawnStreams(request.session, sdp);
      if (streams == null) {
        request.sendResponse(RTSPResponse.badRequest(body: 'path=null'));
      } else {
        request.sendResponse(RTSPResponse.ok());
      }
    }
  }

  void _handleOptions(RTSPRequest request) {
    request.sendResponse(RTSPResponse.options(
      public: RTSPRequestMethod.values.map((e) => e.name).toList(),
    ));
  }

  void _handlePlay(RTSPRequest request) {
    final streams = streamsManager.getStreams(request.session.path);
    if (streams == null) {
      request.sendResponse(RTSPResponse.notFound());
    } else {
      streams.addPlayer(request.session);
      request.sendResponse(RTSPResponse.ok());
    }
  }

  void _handleRecord(RTSPRequest request) {
    final session = request.session;
    final range = request.getHeader(RTSPHeaders.range);
    logger.i('开始推流($range): ${request.path}', session: session);
    sessionsManager.setSessionState(session, RTSPSessionState.recording);
    request.sendResponse(RTSPResponse.ok());
  }

  void _handleSetup(RTSPRequest request) {
    final session = request.session;
    final path = request.path;
    // TCP: RTP/AVP/TCP;unicast;interleaved=0-1;mode=record
    // UDP单播: RTP/AVP/UDP;unicast;client_port=10918-10919;mode=record
    final transport = request.getHeader(RTSPHeaders.transport);
    // TODO: 实现transport解析
    sessionsManager.createSession(session);
    if (transport == null) {
      request.sendResponse(RTSPResponse.badRequest(body: 'transport=null'));
    } else {
      logger.v('设置流: $path\n$transport', session: session);
      // TODO: 实现UDP
      // TCP
      request.sendResponse(RTSPResponse.setup(transport: transport));
    }
  }

  void _handleTeardown(RTSPRequest request) {
    // TODO: 处理
  }

  /// 处理RTP数据
  void _onRTP(RTSPSession session, Uint8List bytes) {
    final streams = streamsManager.getStreams(session.path);
    if (streams == null) {
      return;
    }
    streams.writeRTP(bytes);
  }
}
