/// Serial settings and COM-port selection keys for Windows BT Classic / ELM.
class BtSerialConfig {
  BtSerialConfig._();

  /// Typical ELM327 SPP default: 9600 8N1.
  static const int baudRate = 9600;
  static const int dataBits = 8;

  /// `--dart-define=OBD_COM_PORT=COMx` and process env key.
  static const String comPortKey = 'OBD_COM_PORT';

  /// Bluetooth enumerator / SPP service UUID fragments in hardware IDs.
  static const String bthenumHint = 'BTHENUM';
  static const String sppUuidHint = '00001101';

  /// Friendly-name hints when hardware ID is inconclusive.
  static const List<String> nameHints = ['ELM', 'OBD', 'VGATE'];

  /// Read pump chunk size and idle poll interval for [BtSerialLink].
  static const int readChunkSize = 512;
  static const Duration readPollInterval = Duration(milliseconds: 40);
}
