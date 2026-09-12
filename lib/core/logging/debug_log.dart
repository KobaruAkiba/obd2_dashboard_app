import 'package:flutter/foundation.dart';

/// Logs [message] via [debugPrint] when running in debug mode.
void debugLog(Object? message) {
  if (kDebugMode) {
    debugPrint('$message');
  }
}
