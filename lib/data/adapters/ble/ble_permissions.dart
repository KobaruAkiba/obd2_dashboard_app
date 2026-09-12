import 'dart:io';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:permission_handler/permission_handler.dart';

import 'package:odb_dashboard/core/logging/debug_log.dart';

/// Runtime Bluetooth / location permissions for BLE scanning & connect.
class BlePermissions {
  BlePermissions._();

  static bool get _isAndroid =>
      !kIsWeb &&
      (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.android);

  static bool get _isIos =>
      !kIsWeb &&
      (Platform.isIOS || defaultTargetPlatform == TargetPlatform.iOS);

  /// Request the permissions required on this platform. Returns false if denied.
  static Future<bool> ensure() async {
    if (kIsWeb) {
      debugLog('[BLE] permissions: web unsupported');
      return false;
    }

    if (_isAndroid) {
      final statuses = await <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final scan = statuses[Permission.bluetoothScan];
      final connect = statuses[Permission.bluetoothConnect];
      final location = statuses[Permission.locationWhenInUse];

      debugLog(
        '[BLE] Android perms scan=$scan connect=$connect location=$location',
      );

      final scanOk = scan == null || scan.isGranted || scan.isLimited;
      final connectOk =
          connect == null || connect.isGranted || connect.isLimited;
      // Location is required for BLE scan on many Android versions; treat
      // permanentlyDenied as failure but allow if granted/limited.
      final locationOk =
          location == null || location.isGranted || location.isLimited;

      return scanOk && connectOk && locationOk;
    }

    if (_isIos) {
      // CoreBluetooth prompts via NSBluetoothAlwaysUsageDescription.
      // permission_handler's Permission.bluetooth needs a Podfile macro that
      // this SPM-based ios/ tree may not define — still attempt, but do not
      // hard-fail so flutter_blue_plus can open the system dialog.
      try {
        final status = await Permission.bluetooth.request();
        debugLog('[BLE] iOS bluetooth=$status');
      } catch (e) {
        debugLog('[BLE] iOS permission_handler skipped: $e');
      }
      return true;
    }

    // Desktop / other: no permission_handler path — caller may still try FBP.
    debugLog('[BLE] permissions: platform has no runtime BLE gate');
    return true;
  }
}
