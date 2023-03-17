part of 'connection_manager.dart';

/// 会话管理器
class SessionsManager {
  /// 临时会话
  final _tempSessions = <RTSPSession>[];

  /// 会话
  final _sessions = <String, RTSPSession>{};

  /// 添加会话
  void addSession(RTSPSession session) {
    final sessionId = session.sessionId;
    if (sessionId == null) {
      if (!_tempSessions.contains(session)) {
        _tempSessions.add(session);
        logger.i('添加临时会话', session: session);
      }
    } else {
      _sessions[sessionId] = session;
      logger.i('添加会话', session: session);
    }
  }

  /// 移除会话
  void removeSession(RTSPSession session) {
    if (session.state != RTSPSessionState.disconnected) {
      session.close();
    }
    if (session.temporary) {
      _tempSessions.remove(session);
      logger.i('移除临时会话', session: session);
    } else {
      _sessions.remove(session.sessionId);
      logger.i('移除会话', session: session);
    }
  }

  /// 获取会话
  RTSPSession? getSession(String sessionId) {
    return _sessions[sessionId];
  }

  /// 设置会话路径
  void setSessionPath(RTSPSession session, String path) {
    session._path = path;
  }
}
