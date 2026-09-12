/// Concrete OBD data-source transport selected by [ObdServiceFactory].
enum ObdTransport {
  mock,
  btSerial,
  bleUart,
  canBus,
}

extension ObdTransportX on ObdTransport {
  /// Human-readable label for the UI / stubs.
  String get displayName => switch (this) {
        ObdTransport.mock => 'Mock data',
        ObdTransport.btSerial => 'Bluetooth serial (stub)',
        ObdTransport.bleUart => 'BLE UART (stub)',
        ObdTransport.canBus => 'CAN bus (stub)',
      };
}
