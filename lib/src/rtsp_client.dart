part of 'connection_manager.dart';

/// 客户端状态
enum RTSPClientState {
  // 连接或者连接断开状态
  none,
  // 正在播放
  playing,
  // 正在录制
  recording,
}

/// 客户端
class RTSPClient {
  /// 连接管理器
  final ConnectionManager connectionManager;

  /// 连接
  final Socket socket;

  /// 状态
  RTSPClientState state = RTSPClientState.none;

  /// 路径
  String? path;

  /// 地址
  String get address => socket.remoteAddress.address;

  /// 服务器名称
  String get serverName => connectionManager.serverName;

  RTSPClient._create(
    this.connectionManager, {
    required this.socket,
  });

  /// 发送数据
  void send(Object? data) {
    socket.write(data);
  }

  @override
  String toString() {
    return '[$address]';
  }
}
