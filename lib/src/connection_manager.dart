/// 连接管理器
class ConnectionManager {
  /// 端口
  final int port;

  /// 是否运行中
  bool get running => false;

  ConnectionManager(this.port);

  /// 开始
  Future<bool> start() async {
    return true;
  }

  /// 停止
  void stop() async {}
}
