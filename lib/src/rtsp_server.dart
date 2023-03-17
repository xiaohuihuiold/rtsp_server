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
    // TODO: 处理
  }

  void _handleOptions(RTSPRequest request) {
    request.sendResponse(RTSPResponse.ok(
      headers: {
        RTSPHeaders.public.name:
            RTSPRequestMethod.values.map((e) => e.name).join(', '),
      },
    ));
  }

  void _handlePlay(RTSPRequest request) {
    // TODO: 处理
  }

  void _handleRecord(RTSPRequest request) {
    // TODO: 处理
  }

  void _handleSetup(RTSPRequest request) {
    // TODO: 处理
  }

  void _handleTeardown(RTSPRequest request) {
    // TODO: 处理
  }
}
