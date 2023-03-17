/// 头部解析异常
class RequestHeadException implements Exception {
  final String? method;
  final String? uri;
  final String? message;

  RequestHeadException({this.method, this.uri, this.message});

  @override
  String toString() {
    return 'RequestHeadException(method: $method, uri: $uri, message: $message)';
  }
}

/// 请求方法异常
class RequestMethodException implements Exception {
  final String? method;
  final String? message;

  RequestMethodException({this.method, this.message});

  @override
  String toString() {
    return 'RequestMethodException(method: $method, message: $message)';
  }
}
