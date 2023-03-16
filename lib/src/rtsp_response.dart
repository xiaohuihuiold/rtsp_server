part of 'connection_manager.dart';

/// RTSP响应
class RTSPResponse {
  /// 状态码
  final int statusCode;

  /// 响应头
  final Map<String, String> headers;

  /// 响应内容
  final String? body;

  /// CSeq
  String? cSeq;

  /// 服务器名称
  String? _serverName;

  RTSPResponse._create({
    required this.statusCode,
    required this.headers,
    this.body,
    this.cSeq,
  });

  factory RTSPResponse.ok({
    String? cSeq,
    Map<String, String>? headers,
    String? body,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      statusCode: 200,
      headers: {...?headers},
      body: body,
    );
  }

  /// 生成响应文本
  String toResponseText() {
    final stringBuffer = StringBuffer();
    stringBuffer.write('RTSP/1.0 $statusCode OK\r\n');

    // 填充headers
    String? cSeq = this.cSeq ?? headers[RTSPHeaders.cSeq.name];
    if (cSeq != null) {
      headers[RTSPHeaders.cSeq.name] = cSeq;
    }
    headers[RTSPHeaders.server.name] = _serverName ?? 'unknown';
    for (final entry in headers.entries) {
      stringBuffer.write('${entry.key}: ${entry.value}\r\n');
    }
    stringBuffer.write('\r\n');

    // 填充body
    if (body != null) {
      stringBuffer.write(body);
      stringBuffer.write('\r\n');
    }

    return stringBuffer.toString();
  }
}
