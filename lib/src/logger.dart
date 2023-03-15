import 'dart:io';

import 'package:logger/logger.dart';

final logger = LoggerWrapper();

/// 自定义日志
class LoggerWrapper {
  final logger = Logger(printer: SimplePrinter());

  void v(
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.verbose,
      message,
      socket: socket,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void d(
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.debug,
      message,
      socket: socket,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void i(
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.info,
      message,
      socket: socket,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void w(
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.warning,
      message,
      socket: socket,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void e(
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.error,
      message,
      socket: socket,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void wtf(
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.wtf,
      message,
      socket: socket,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void log(
    Level level,
    dynamic message, {
    Socket? socket,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (socket != null) {
      message = '[${_getAddress(socket)}]: $message';
    }
    logger.log(level, message, error, stackTrace);
  }

  String? _getAddress(Socket? socket) {
    return socket?.remoteAddress.address;
  }
}
