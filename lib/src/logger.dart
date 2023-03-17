import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:logger/logger.dart';
import 'connection_manager.dart';

final logger = LoggerWrapper();

/// 自定义日志
class LoggerWrapper {
  final logger = Logger(
    printer: HybridPrinter(
      MySimplePrinter(),
      error: PrettyPrinter(
        printTime: true,
        stackTraceBeginIndex: 2,
        methodCount: 4,
        noBoxingByDefault: true,
      ),
    ),
  );

  void v(
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.verbose,
      message,
      session: session,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void d(
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.debug,
      message,
      session: session,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void i(
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.info,
      message,
      session: session,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void w(
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.warning,
      message,
      session: session,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void e(
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.error,
      message,
      session: session,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void wtf(
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.wtf,
      message,
      session: session,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void log(
    Level level,
    dynamic message, {
    RTSPSession? session,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (session != null) {
      message = '[${session.address}]: $message';
    }
    logger.log(level, message, error, stackTrace);
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
