part of 'connection_manager.dart';

/// 客户端状态
enum RTSPSessionState {
  // 连接状态
  none,
  // 正在播放
  playing,
  // 正在录制
  recording,
  // 断开连接
  disconnected,
}

/// 客户端
class RTSPSession {
  /// 服务器名称
  final String serverName;

  /// 连接
  final Socket _socket;

  /// 状态
  RTSPSessionState _state = RTSPSessionState.none;

  RTSPSessionState get state => _state;

  /// 路径
  String? _path;

  String? get path => _path;

  /// 会话
  String? _sessionId;

  String? get sessionId => _sessionId;

  /// 是否是临时会话
  bool get temporary => _sessionId == null;

  /// 地址
  String get address => _socket.remoteAddress.address;

  RTSPSession._create({
    required this.serverName,
    required Socket socket,
  }) : _socket = socket;

  /// 初始化sessionId
  void initSession() {
    _sessionId ??= const Uuid().v4();
  }

  /// 发送数据
  void sendResponse(RTSPResponse response) {
    response._serverName = serverName;
    response.session = sessionId;
    send(response.toResponseText());
    logger.v(
      '${response.status.code}: ${response.status.message}',
      session: this,
    );
  }

  /// 发送数据
  void send(Object? data) {
    _socket.write(data);
  }

  /// 关闭连接
  void close() {
    _socket.close();
  }

  /// 监听socket数据
  void _listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _socket.listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  @override
  String toString() {
    return '[$address]';
  }
}
