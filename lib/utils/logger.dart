import 'package:flutter/foundation.dart';

class Logger {
  final String _tag;

  Logger(this._tag);

  void d(String message) {
    print('[$_tag] DEBUG: $message');
  }

  void i(String message) {
    print('[$_tag] INFO: $message');
  }

  void w(String message) {
    print('[$_tag] WARN: $message');
  }

  void e(String message) {
    print('[$_tag] ERROR: $message');
  }
}
