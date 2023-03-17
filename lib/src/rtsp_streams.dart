part of 'streams_manager.dart';

/// RTSP流
class RTSPStreams {
  /// 路径
  final String path;

  /// sdp
  final String sdp;

  /// 媒体流
  final streams = <MediaStream>[];

  /// 推流端
  final RTSPSession recorder;

  /// 播放端
  final players = <RTSPSession>[];

  RTSPStreams._create({
    required this.path,
    required this.sdp,
    required this.recorder,
  });
}

/// 媒体流
class MediaStream {}
