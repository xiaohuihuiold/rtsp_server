part of 'connection_manager.dart';

/// 响应状态
enum RTSPResponseStatus {
  ok(200, 'OK'),
  badRequest(400, 'Bad Request'),
  unauthorized(401, 'Unauthorized'),
  forbidden(403, 'Forbidden'),
  notFound(404, 'Not Found'),
  methodNotAllowed(404, 'Method Not Allowed'),
  internalServerError(500, 'Internal Server Error');

  final int code;
  final String message;

  const RTSPResponseStatus(this.code, this.message);
}

/// RTSP响应
class RTSPResponse {
  /// 状态码
  final RTSPResponseStatus status;

  /// 响应头
  final Map<String, String> headers;

  /// 响应内容
  final String? body;

  /// CSeq
  String? cSeq;

  /// session
  String? session;

  /// 服务器名称
  String? _serverName;

  RTSPResponse._create({
    required this.status,
    required this.headers,
    this.body,
    this.cSeq,
    this.session,
  });

  factory RTSPResponse.ok({
    String? cSeq,
    String? session,
    Map<String, String>? headers,
    String? body,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.ok,
      headers: {...?headers},
      body: body,
      session: session,
    );
  }

  factory RTSPResponse.badRequest({
    String? body,
    String? cSeq,
    Map<String, String>? headers,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.badRequest,
      headers: {...?headers},
      body: body ?? RTSPResponseStatus.badRequest.message,
    );
  }

  factory RTSPResponse.unauthorized({
    String? body,
    String? cSeq,
    Map<String, String>? headers,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.unauthorized,
      headers: {...?headers},
      body: body ?? RTSPResponseStatus.badRequest.message,
    );
  }

  factory RTSPResponse.forbidden({
    String? body,
    String? cSeq,
    Map<String, String>? headers,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.forbidden,
      headers: {...?headers},
      body: body ?? RTSPResponseStatus.badRequest.message,
    );
  }

  factory RTSPResponse.notFound({
    String? body,
    String? cSeq,
    Map<String, String>? headers,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.notFound,
      headers: {...?headers},
      body: body ?? RTSPResponseStatus.badRequest.message,
    );
  }

  factory RTSPResponse.methodNotAllowed({
    String? body,
    String? cSeq,
    Map<String, String>? headers,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.notFound,
      headers: {...?headers},
      body: body ?? RTSPResponseStatus.badRequest.message,
    );
  }

  factory RTSPResponse.internalServerError({
    String? body,
    String? cSeq,
    Map<String, String>? headers,
  }) {
    return RTSPResponse._create(
      cSeq: cSeq,
      status: RTSPResponseStatus.internalServerError,
      headers: {...?headers},
      body: body ?? RTSPResponseStatus.badRequest.message,
    );
  }

  /// 生成响应文本
  String toResponseText() {
    final stringBuffer = StringBuffer();
    stringBuffer.write('RTSP/1.0 ${status.code} ${status.message}\r\n');

    // 填充headers
    String? cSeq = this.cSeq ?? headers[RTSPHeaders.cSeq.name];
    if (cSeq != null) {
      headers[RTSPHeaders.cSeq.name] = cSeq;
    }
    headers[RTSPHeaders.server.name] = _serverName ?? 'unknown';
    final session = this.session;
    if (session != null) {
      headers[RTSPHeaders.session.name] = session;
    }
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
