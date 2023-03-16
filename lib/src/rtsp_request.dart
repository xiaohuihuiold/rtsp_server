part of 'connection_manager.dart';

/// 请求方法
enum RTSPRequestMethod {
  // 请求媒体描述
  describe('DESCRIBE'),
  // 更新服务器或者客户端的媒体描述
  announce('ANNOUNCE'),
  // 获取服务支持的方法
  options('OPTIONS'),
  // 客户端可以开始播放数据
  play('PLAY'),
  // 服务端可以开始记录数据
  record('RECORD'),
  // 设置流
  setup('SETUP'),
  // 停止发送数据
  teardown('TEARDOWN');

  final String method;

  const RTSPRequestMethod(this.method);
}

/// RTSP请求
class RTSPRequest {
  /// 客户端
  final RTSPClient client;

  /// 请求方法
  final RTSPRequestMethod method;

  /// URI
  final Uri uri;

  /// 请求头
  final Map<String, String> headers;

  /// 内容
  final String? data;

  RTSPRequest._create({
    required this.client,
    required this.method,
    required this.uri,
    required this.headers,
    this.data,
  });

  factory RTSPRequest._fromBytes(RTSPClient client, Uint8List bytes) {
    return RTSPRequest._fromString(client, utf8.decode(bytes));
  }

  factory RTSPRequest._fromString(RTSPClient client, String data) {
    final lines = data.split('\r\n');

    // 查找头部信息
    final headReg = RegExp(r'(\w+) (\S+) RTSP');
    final headMatch = headReg.firstMatch(lines[0]);
    final methodStr = headMatch?.group(1);
    final uriStr = headMatch?.group(2);
    if (uriStr == null || methodStr == null) {
      throw Exception('method: $methodStr, uri: $uriStr');
    }
    final method = RTSPRequestMethod.values
        .firstWhereOrNull((element) => element.method == methodStr);
    if (method == null) {
      throw Exception('不支持的方法: $methodStr');
    }

    // 查找请求头
    final headers = <String, String>{};
    int headersEndIndex = 1;
    headersEndIndex = lines.indexWhere((element) {
      if (element.isEmpty) {
        return true;
      }
      final mid = element.indexOf(':');
      final key = element.substring(0, mid).trim();
      final value = element.substring(mid + 1).trim();
      headers[key] = value;
      return false;
    }, headersEndIndex);

    // 查找请求内容
    int bodyBeginIndex = headersEndIndex;
    bodyBeginIndex =
        lines.indexWhere((element) => element.isNotEmpty, bodyBeginIndex);
    if (bodyBeginIndex != -1) {
      // TODO: 处理请求内容
    }

    return RTSPRequest._create(
      client: client,
      method: method,
      uri: Uri.parse(uriStr),
      headers: headers,
    );
  }

  @override
  String toString() {
    return 'RTSPRequest(${method.method}, ${client.address}): ${uri.path}';
  }
}
