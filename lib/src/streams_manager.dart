import 'dart:collection';
import 'dart:typed_data';

import 'package:rtsp_server/src/connection_manager.dart';
import 'package:rtsp_server/src/logger.dart';
import 'package:rtsp_server/src/rtp_packet.dart';

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
    final streams =
        RTSPStreams._create(path: path, sdp: sdp, recorder: session);
    _streams[path] = streams;
    logger.i('创建流: $path', session: session);
    return streams;
  }

  /// 销毁流
  void destroyStreams(RTSPStreams streams) {
    logger.i('销毁流: ${streams.path}');
    _streams.remove(streams.path);
    streams._destroy();
  }

  /// 获取流
  RTSPStreams? getStreams(String? path) {
    return _streams[path];
  }
}
