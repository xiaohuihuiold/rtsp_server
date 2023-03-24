import 'dart:typed_data';

import 'package:collection/collection.dart';

/// payload类型
enum RTPPayloadType {
  unknown(-1),
  h264(96),
  aac(97);

  final int type;

  const RTPPayloadType(this.type);
}

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
  final RTPPayloadType payloadType;

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
  final List<int> csrc;

  /// payload
  final Uint8List payload;

  RTPPacket({
    required this.version,
    required this.padding,
    required this.extension,
    required this.csrcLength,
    required this.marker,
    required int payloadType,
    required this.seq,
    required this.timestamp,
    required this.ssrc,
    required this.csrc,
    required this.payload,
  }) : payloadType = RTPPayloadType.values.firstWhere(
            (e) => e.type == payloadType,
            orElse: () => RTPPayloadType.unknown);

  Uint8List toBytes() {
    final rtpLength = 12 + csrcLength + payload.length;
    final byteData = ByteData(4 + rtpLength);
    int offset = 0;
    byteData.setUint8(offset, 0x24);
    offset += 1;
    if (payloadType == RTPPayloadType.aac) {
      byteData.setUint8(offset, 0x02);
    } else {
      byteData.setUint8(offset, 0x0);
    }
    offset += 1;
    byteData.setUint16(offset, rtpLength);
    offset += 2;

    // RTP
    byteData.setUint8(offset,
        (version << 6) | (padding << 5) | (extension << 4) | (csrcLength));
    offset += 1;
    byteData.setUint8(offset, (marker << 7) | payloadType.type);
    offset += 1;
    byteData.setUint16(offset, seq);
    offset += 2;
    byteData.setUint32(offset, timestamp);
    offset += 4;
    byteData.setUint32(offset, ssrc);
    offset += 4;
    for (int i = 0; i < csrc.length; i++) {
      byteData.setUint32(offset, csrc[i]);
      offset += 4;
    }
    for (int i = 0; i < payload.length; i++) {
      byteData.setUint8(offset, payload[i]);
      offset += 1;
    }
    return byteData.buffer.asUint8List();
  }

  @override
  String toString() {
    return 'RTPPacket(v: $version, p: $padding, x: $extension, cc: $csrcLength, m: $marker, pt: $payloadType, seq: $seq, timestamp: $timestamp, ssrc: $ssrc, csrc: $csrc)';
  }
}
