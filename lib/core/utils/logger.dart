import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging and tracking operations
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';

  /// Log debug message
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('$_blue DEBUG $_reset$prefix$message');
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('$_green INFO $_reset$prefix$message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('$_yellow WARNING $_reset$prefix$message');
    }
  }

  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('$_red ERROR $_reset$prefix$message');
      if (error != null) {
        print('$_red ERROR $_reset$prefix$error');
      }
      if (stackTrace != null) {
        print('$_red STACK TRACE $_reset$prefix$stackTrace');
      }
    }
  }

  /// Log database operation
  static void database(String operation, {String? details}) {
    if (kDebugMode) {
      final detailsStr = details != null ? ' - $details' : '';
      print('$_magenta DATABASE $_reset$operation$detailsStr');
    }
  }

  /// Log use case execution
  static void useCase(String useCase, {String? details}) {
    if (kDebugMode) {
      final detailsStr = details != null ? ' - $details' : '';
      print('$_blue USE CASE $_reset$useCase$detailsStr');
    }
  }

  /// Log UI event
  static void ui(String event, {String? details}) {
    if (kDebugMode) {
      final detailsStr = details != null ? ' - $details' : '';
      print('$_green UI $_reset$event$detailsStr');
    }
  }

  /// Log service operation
  static void service(String operation, {String? details}) {
    if (kDebugMode) {
      final detailsStr = details != null ? ' - $details' : '';
      print('$_magenta SERVICE $_reset$operation$detailsStr');
    }
  }
}
