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

/// 客户端角色
enum RTSPSessionRole {
  // 未知
  none,
  // 播放
  player,
  // 推流
  recorder,
}

/// 客户端
class RTSPSession {
  /// 服务器名称
  final String serverName;

  /// 连接
  final Socket _socket;

  /// 锁
  final _lock = Lock();

  /// 状态
  RTSPSessionState _state = RTSPSessionState.none;

  RTSPSessionState get state => _state;

  /// 角色
  RTSPSessionRole _role = RTSPSessionRole.none;

  RTSPSessionRole get role => _role;

  /// 路径
  String? _path;

  String? get path => _path;

  /// 会话
  String? _sessionId;

  String? get sessionId => _sessionId;

  /// 是否是临时会话
  bool get temporary => _sessionId == null;

  String _address = '---.---.---.---';

  /// 地址
  String get address {
    try {
      _address = _socket.remoteAddress.address;
      return _address;
    } catch (e) {
      return _address;
    }
  }

  RTSPSession._create({
    required this.serverName,
    required Socket socket,
  }) : _socket = socket;

  /// 发送数据
  void sendResponse(RTSPResponse response) {
    response._serverName = serverName;
    response.session = sessionId;
    logger.v(
      '${response.status.code}: ${response.status.message}${response.body == null ? '' : '\n${response.body}'}',
      session: this,
    );
    send(response.toResponseText());
  }

  /// 发送数据
  void send(Object? data) async {
    await _lock.synchronized(() async {
      if (state == RTSPSessionState.disconnected) {
        return;
      }
      try {
        await _socket.flush();
        if (data is List<int>) {
          _socket.add(data);
        } else {
          _socket.write(data);
        }
      } catch (e) {
        _state = RTSPSessionState.disconnected;
        logger.w('连接已断开', session: this);
      }
    });
  }

  /// 关闭连接
  void _close() async {
    await _lock.synchronized(() async {
      _state = RTSPSessionState.disconnected;
      try {
        _socket.close();
      } catch (e) {
        logger.nope();
      }
    });
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
