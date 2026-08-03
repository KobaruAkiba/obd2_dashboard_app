import 'package:flutter/foundation.dart';

/// Prints the given object to the console if the app is running in debug mode.
/// @param object The object to print.
void printIfDebug(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}
