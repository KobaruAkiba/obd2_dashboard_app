import 'dart:async';

import 'package:odb_dashboard/core/connection/connection_error_markers.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Maps low-level connection failures (BLE / BT serial / CAN) to short,
/// user-facing messages for the dashboard banner.
///
/// Prefer matching [ConnectionErrorMarkers] from adapter throw sites. Broader
/// heuristics (permissions / access denied) are last-resort only for
/// platform or plugin errors that do not use our markers.
class ConnectionErrorService {
  const ConnectionErrorService();

  /// Returns a readable message for [error], optionally scoped by [transport].
  String userMessage(Object error, {ObdTransport? transport}) {
    final raw = _rawMessage(error).toLowerCase();

    final known = _mapKnown(error: error, raw: raw);
    if (known != null) return known;

    return fallbackMessage(transport: transport);
  }

  /// Transport-scoped message when no specific error payload is available.
  String fallbackMessage({ObdTransport? transport}) => _fallback(transport);

  String? _mapKnown({required Object error, required String raw}) {
    for (final rule in _markerRules) {
      if (raw.contains(rule.marker.toLowerCase())) {
        return rule.message;
      }
    }

    // Typed timeout without a known marker (e.g. generic TimeoutException).
    if (error is TimeoutException) {
      return _adapterTimeoutMessage;
    }

    // Platform / plugin errors that may not use our markers.
    if (raw.contains('permission')) {
      return 'A required permission was denied. Check system settings and try again.';
    }
    if (raw.contains('access is denied') ||
        raw.contains('access denied') ||
        raw.contains('already in use') ||
        raw.contains('is busy') ||
        raw.contains('port busy')) {
      return 'The connection port is busy or inaccessible. Close other apps using it and try again.';
    }

    return null;
  }

  String _fallback(ObdTransport? transport) {
    return switch (transport) {
      ObdTransport.bleUart =>
        'Bluetooth LE connection failed. Check that the adapter is on and in range.',
      ObdTransport.btSerial =>
        'Bluetooth serial connection failed. Check pairing and the COM port.',
      ObdTransport.canBus =>
        'CAN bus connection failed. Check the PCAN device and drivers.',
      ObdTransport.mock => 'Could not start the data source.',
      null => 'Connection failed. Check the adapter and try again.',
    };
  }

  static String _rawMessage(Object error) {
    if (error is StateError) return error.message;
    if (error is TimeoutException) {
      return error.message ?? error.toString();
    }
    return error.toString();
  }
}

const _adapterTimeoutMessage =
    'The OBD adapter did not respond in time. Check power, pairing, and try again.';

const _ecuTimeoutMessage =
    'No response from the vehicle ECU over CAN. Check ignition and wiring.';

/// Ordered marker → copy pairs (first match wins). Keep specific phrases before
/// any broader marker that could overlap.
const _markerRules = <({String marker, String message})>[
  // BLE
  (
    marker: ConnectionErrorMarkers.blePermissionsDenied,
    message:
        'Bluetooth permission denied. Enable it in system settings and try again.',
  ),
  (
    marker: ConnectionErrorMarkers.bleNotSupported,
    message: 'Bluetooth LE is not supported on this device.',
  ),
  (
    marker: ConnectionErrorMarkers.bluetoothOff,
    message: 'Bluetooth is turned off. Turn it on and try again.',
  ),
  (
    marker: ConnectionErrorMarkers.noBleDevices,
    message:
        'No Bluetooth OBD adapter found. Put the dongle nearby in pairing mode and try again.',
  ),
  (
    marker: ConnectionErrorMarkers.noUartRxTx,
    message:
        'The Bluetooth device does not expose a UART OBD interface. Try another adapter.',
  ),
  // BT serial
  (
    marker: ConnectionErrorMarkers.btSerialWindowsOnly,
    message:
        'Bluetooth serial (COM) is only available on Windows. Use BLE UART on this device.',
  ),
  (
    marker: ConnectionErrorMarkers.noObdComPort,
    message:
        'No paired OBD Bluetooth COM port found. Pair the adapter in Windows Settings, then retry.',
  ),
  (
    marker: ConnectionErrorMarkers.btSerialWriteTimedOut,
    message:
        'The Bluetooth serial port stopped responding. Re-pair the adapter and try again.',
  ),
  (
    marker: ConnectionErrorMarkers.btSerialNotOpen,
    message:
        'The Bluetooth serial port stopped responding. Re-pair the adapter and try again.',
  ),
  // CAN / PCAN
  (
    marker: ConnectionErrorMarkers.pcanDllLoadFailed,
    message:
        'PCAN drivers not found. Install PEAK PCAN-Basic and restart the app.',
  ),
  (
    marker: ConnectionErrorMarkers.canInitializeFailed,
    message:
        'Could not open the CAN interface. Check that the PCAN device is connected and not used by another app.',
  ),
  (
    marker: ConnectionErrorMarkers.pcanChannelNotOpen,
    message:
        'CAN bus communication failed. Check the PCAN cable and channel settings.',
  ),
  (
    marker: ConnectionErrorMarkers.canWriteFailed,
    message:
        'CAN bus communication failed. Check the PCAN cable and channel settings.',
  ),
  // Timeouts (ISO-TP before generic ELM)
  (
    marker: ConnectionErrorMarkers.isotpTimeout,
    message: _ecuTimeoutMessage,
  ),
  (
    marker: ConnectionErrorMarkers.elmTimeout,
    message: _adapterTimeoutMessage,
  ),
];
