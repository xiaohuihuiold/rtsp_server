import 'dart:typed_data';

/// RTP包
class RTPPacket {
  /// 2bit
  /// RTP版本
  final int version;

  /// 1bit
  /// 填充,等于1时在末尾有一个8bit填充
  final int padding;

  /// 1bit
  /// 扩展,等于1时在header有一个扩展
  final int extension;

  /// 4bit
  /// csrc长度
  final int csrcLength;

  /// 1bit
  /// 标记,等于1时视频表示一帧结束,音频表示会话开始
  final int marker;

  /// 7bit
  /// payload类型
  final int payloadType;

  /// 16bit
  /// 序列号
  final int seq;

  /// 32bit
  /// 时间戳
  final int timestamp;

  /// 32bit
  /// ssrc
  final int ssrc;

  /// 32bit
  /// csrc
  final int csrc;

  /// payload
  final Uint8List payload;

  RTPPacket({
    required this.version,
    required this.padding,
    required this.extension,
    required this.csrcLength,
    required this.marker,
    required this.payloadType,
    required this.seq,
    required this.timestamp,
    required this.ssrc,
    required this.csrc,
    required this.payload,
  });
}
