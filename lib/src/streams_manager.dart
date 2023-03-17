import 'package:rtsp_server/src/connection_manager.dart';

part 'rtsp_streams.dart';

/// 流管理器
class StreamsManager {
  /// 所有流
  final _streams = <String, RTSPStreams>{};

  /// 创建流
  RTSPStreams? spawnStreams(RTSPSession session, String sdp) {
    final path = session.path;
    if (path == null) {
      return null;
    }
    return RTSPStreams._create(path: path, sdp: sdp, recorder: session);
  }

  /// 获取流
  RTSPStreams? getStreams(String? path) {
    return _streams[path];
  }
}
