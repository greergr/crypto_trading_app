import 'package:flutter/foundation.dart';

class Logger {
  final String tag;

  Logger([this.tag = '']);

  void d(String message) {
    _log('DEBUG', message);
  }

  void i(String message) {
    _log('INFO', message);
  }

  void w(String message) {
    _log('WARN', message);
  }

  void e(String message) {
    _log('ERROR', message);
  }

  void _log(String level, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final prefix = tag.isNotEmpty ? '[$tag]' : '';
      print('$timestamp $level $prefix $message');
    }
  }
}
