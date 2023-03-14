import 'connection_manager.dart';

/// rtsp服务
class RTSPServer {
  /// 端口
  final int port;

  /// 名称
  final String serverName;

  /// 连接管理器
  ConnectionManager? _connectionManager;

  RTSPServer({
    required this.port,
    this.serverName = 'rtspserver',
  });

  Future<bool> start() async {
    if (_connectionManager?.running == true) {
      return true;
    }
    _connectionManager?.stop();
    _connectionManager = ConnectionManager(port);
    return await _connectionManager?.start() == true;
  }

  void stop() {}
}
