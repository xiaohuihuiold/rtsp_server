import 'package:rtsp_server/src/logger.dart';

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
  }

  void _handleDescribe(RTSPRequest request) {
    // TODO: 处理
  }

  void _handleAnnounce(RTSPRequest request) {
    final sdp = request.body;
    if (sdp == null) {
      request.sendResponse(RTSPResponse.badRequest());
    } else {
      logger.v('设置sdp数据: \n$sdp', session: request.session);
      request.sendResponse(RTSPResponse.ok());
    }
  }

  void _handleOptions(RTSPRequest request) {
    request.sendResponse(RTSPResponse.options(
      public: RTSPRequestMethod.values.map((e) => e.name).toList(),
    ));
  }

  void _handlePlay(RTSPRequest request) {
    // TODO: 处理
  }

  void _handleRecord(RTSPRequest request) {
    // TODO: 处理
  }

  void _handleSetup(RTSPRequest request) {
    final path = request.path;
    // TCP: RTP/AVP/TCP;unicast;interleaved=0-1;mode=record
    // UDP单播: RTP/AVP/UDP;unicast;client_port=10918-10919;mode=record
    final transport = request.getHeader(RTSPHeaders.transport);
    // TODO: 实现transport解析
    request.session.initSession();
    if (transport == null) {
      request.sendResponse(RTSPResponse.badRequest());
    } else {
      logger.v('设置流: $path\n$transport', session: request.session);
      // TODO: 实现UDP
      // TCP
      request.sendResponse(RTSPResponse.setup(transport: transport));
    }
  }

  void _handleTeardown(RTSPRequest request) {
    // TODO: 处理
  }
}
