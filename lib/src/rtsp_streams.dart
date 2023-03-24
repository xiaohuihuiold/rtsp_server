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

  /// 视频队列
  final videoQueue = Queue<RTPPacket>();

  /// 音频队列
  final audioQueue = Queue<RTPPacket>();

  RTSPStreams._create({
    required this.path,
    required this.sdp,
    required this.recorder,
  });

  /// 添加播放器
  void addPlayer(RTSPSession session) {
    players.add(session);
  }

  /// 移除播放器
  void removePlayer(RTSPSession session) {
    players.remove(session);
  }

  /// 写入数据
  void writeRTP(RTPPacket packet) {
    if (packet.payloadType == RTPPayloadType.h264) {
      videoQueue.addLast(packet);
    } else {
      audioQueue.addLast(packet);
    }
    if (videoQueue.length > 10) {
      final bytes = videoQueue.removeFirst().toBytes();
      for (final player in players) {
        player.send(bytes);
      }
    }
    if (audioQueue.length > 10) {
      final bytes = audioQueue.removeFirst().toBytes();
      for (final player in players) {
        player.send(bytes);
      }
    }
  }

  /// 销毁
  void _destroy() {
    players.clear();
    streams.clear();
  }
}

/// 媒体流
class MediaStream {}
