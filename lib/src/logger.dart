import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:logger/logger.dart';

final logger = LoggerWrapper();

/// 自定义日志
class LoggerWrapper {
  final logger = Logger(
    printer: HybridPrinter(
      MySimplePrinter(),
      error: PrettyPrinter(printTime: true),
    ),
  );

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

/// 自定义简单日志
class MySimplePrinter extends SimplePrinter {
  static final grey = AnsiColor.fg(8);
  static final timeFormat = [HH, ':', nn, ':', ss];

  MySimplePrinter() : super(printTime: true, colors: true);

  @override
  List<String> log(LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    var timeStr = printTime ? grey(formatDate(event.time, timeFormat)) : '';
    return ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];
  }

  String _labelFor(Level level) {
    var prefix = SimplePrinter.levelPrefixes[level]!;
    var color = SimplePrinter.levelColors[level]!;
    return colors ? color(prefix) : prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = const JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}
