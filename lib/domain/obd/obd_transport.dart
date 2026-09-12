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
        ObdTransport.btSerial => 'Bluetooth serial',
        ObdTransport.bleUart => 'BLE UART',
        ObdTransport.canBus => 'CAN bus (stub)',
      };
}
