import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/core/connection/connection_error_markers.dart';
import 'package:odb_dashboard/core/connection/connection_error_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

void main() {
  const service = ConnectionErrorService();

  group('ConnectionErrorService', () {
    test('maps BLE permission and adapter errors via markers', () {
      expect(
        service.userMessage(
          StateError(ConnectionErrorMarkers.blePermissionsDenied),
          transport: ObdTransport.bleUart,
        ),
        'Bluetooth permission denied. Enable it in system settings and try again.',
      );
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.bluetoothOff} — turn it on and retry',
          ),
          transport: ObdTransport.bleUart,
        ),
        'Bluetooth is turned off. Turn it on and try again.',
      );
      expect(
        service.userMessage(
          StateError('${ConnectionErrorMarkers.noBleDevices} during scan'),
          transport: ObdTransport.bleUart,
        ),
        'No Bluetooth OBD adapter found. Put the dongle nearby in pairing mode and try again.',
      );
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.noUartRxTx} characteristics found',
          ),
          transport: ObdTransport.bleUart,
        ),
        'The Bluetooth device does not expose a UART OBD interface. Try another adapter.',
      );
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.bleNotSupported} on this device',
          ),
          transport: ObdTransport.bleUart,
        ),
        'Bluetooth LE is not supported on this device.',
      );
    });

    test('maps BT serial COM errors via markers', () {
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.noObdComPort} found. Pair the ELM…',
          ),
          transport: ObdTransport.btSerial,
        ),
        'No paired OBD Bluetooth COM port found. Pair the adapter in Windows Settings, then retry.',
      );
      expect(
        service.userMessage(
          StateError(
            'BT serial (COM) is ${ConnectionErrorMarkers.btSerialWindowsOnly}.',
          ),
          transport: ObdTransport.btSerial,
        ),
        'Bluetooth serial (COM) is only available on Windows. Use BLE UART on this device.',
      );
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.btSerialWriteTimedOut} on COM5',
          ),
          transport: ObdTransport.btSerial,
        ),
        'The Bluetooth serial port stopped responding. Re-pair the adapter and try again.',
      );
      expect(
        service.userMessage(
          StateError(ConnectionErrorMarkers.btSerialNotOpen),
          transport: ObdTransport.btSerial,
        ),
        'The Bluetooth serial port stopped responding. Re-pair the adapter and try again.',
      );
    });

    test('maps CAN / PCAN errors via markers', () {
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.pcanDllLoadFailed}: could not load '
            'PCANBasic.dll.',
          ),
          transport: ObdTransport.canBus,
        ),
        'PCAN drivers not found. Install PEAK PCAN-Basic and restart the app.',
      );
      expect(
        service.userMessage(
          StateError(
            '${ConnectionErrorMarkers.canInitializeFailed} for channel 0x51 '
            'baud=0x001c: status=0x2. Check that the PCAN device is connected '
            'and not in use.',
          ),
          transport: ObdTransport.canBus,
        ),
        'Could not open the CAN interface. Check that the PCAN device is connected and not used by another app.',
      );
      expect(
        service.userMessage(
          StateError(ConnectionErrorMarkers.pcanChannelNotOpen),
          transport: ObdTransport.canBus,
        ),
        'CAN bus communication failed. Check the PCAN cable and channel settings.',
      );
    });

    test('maps ELM / ISO-TP timeouts', () {
      expect(
        service.userMessage(
          TimeoutException(
            '${ConnectionErrorMarkers.elmTimeout} waiting for ATZ',
          ),
          transport: ObdTransport.bleUart,
        ),
        'The OBD adapter did not respond in time. Check power, pairing, and try again.',
      );
      expect(
        service.userMessage(
          TimeoutException(ConnectionErrorMarkers.isotpTimeout),
          transport: ObdTransport.canBus,
        ),
        'No response from the vehicle ECU over CAN. Check ignition and wiring.',
      );
      expect(
        service.userMessage(
          TimeoutException('generic wait'),
          transport: ObdTransport.bleUart,
        ),
        'The OBD adapter did not respond in time. Check power, pairing, and try again.',
      );
    });

    test('uses narrow busy/access heuristics without false positives', () {
      expect(
        service.userMessage(
          Exception('Access is denied'),
          transport: ObdTransport.btSerial,
        ),
        'The connection port is busy or inaccessible. Close other apps using it and try again.',
      );
      expect(
        service.userMessage(
          Exception('COM5 is already in use'),
          transport: ObdTransport.btSerial,
        ),
        'The connection port is busy or inaccessible. Close other apps using it and try again.',
      );
      // "not in use" must not match the busy heuristic when no marker matches.
      expect(
        service.userMessage(
          Exception('device is not in use'),
          transport: ObdTransport.canBus,
        ),
        'CAN bus connection failed. Check the PCAN device and drivers.',
      );
    });

    test('falls back by transport for unknown errors', () {
      expect(
        service.userMessage(Exception('boom'), transport: ObdTransport.bleUart),
        'Bluetooth LE connection failed. Check that the adapter is on and in range.',
      );
      expect(
        service.userMessage(Exception('boom'), transport: ObdTransport.btSerial),
        'Bluetooth serial connection failed. Check pairing and the COM port.',
      );
      expect(
        service.userMessage(Exception('boom'), transport: ObdTransport.canBus),
        'CAN bus connection failed. Check the PCAN device and drivers.',
      );
      expect(
        service.fallbackMessage(transport: ObdTransport.mock),
        'Could not start the data source.',
      );
      expect(
        service.fallbackMessage(),
        'Connection failed. Check the adapter and try again.',
      );
    });
  });
}
