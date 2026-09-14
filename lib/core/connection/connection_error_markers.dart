/// Stable phrases embedded in adapter [StateError] / [TimeoutException] text.
///
/// Throw sites in BLE / BT serial / CAN / ELM / ISO-TP adapters should use
/// these constants so [ConnectionErrorService] can map failures without
/// depending on free-form wording drift.
abstract final class ConnectionErrorMarkers {
  // --- BLE ---
  static const blePermissionsDenied = 'Bluetooth permissions denied';
  static const bleNotSupported = 'Bluetooth LE is not supported';
  static const bluetoothOff = 'Bluetooth is off';
  static const noBleDevices = 'No BLE devices found';
  static const noUartRxTx = 'No UART RX/TX';

  // --- BT serial (Windows COM) ---
  static const btSerialWindowsOnly = 'only supported on Windows';
  static const noObdComPort = 'No OBD Bluetooth COM port';
  static const btSerialWriteTimedOut = 'BT serial write timed out';
  static const btSerialNotOpen = 'BT serial COM not open';

  // --- CAN / PCAN ---
  static const pcanDllLoadFailed = 'PCAN DLL load failed';
  static const canInitializeFailed = 'CAN_Initialize failed';
  static const pcanChannelNotOpen = 'PCAN channel is not open';
  static const canWriteFailed = 'CAN_Write failed';

  // --- ELM327 / ISO-TP ---
  static const elmTimeout = 'ELM timeout';
  static const isotpTimeout = 'ISO-TP response timeout';
}
