/// SAE J1979 Mode $01 PID helpers.
///
/// Bytes A/B are payload bytes after the `41 XX` response header.
class PidParser {
  PidParser._();

  /// PID 0x0C — Engine RPM: ((A * 256) + B) / 4
  static double rpm(int a, int b) => ((a * 256) + b) / 4.0;

  /// PID 0x0D — Vehicle speed (km/h)
  static double speedKmh(int a) => a.toDouble();

  /// PID 0x05 / 0x0F — Temperature (°C): A − 40
  static double tempC(int a) => a - 40.0;

  /// PID 0x04 / 0x11 / 0x2F — Percentage: A * 100 / 255
  static double percent(int a) => a * 100.0 / 255.0;

  /// PID 0x42 — Control module voltage (V): ((A * 256) + B) / 1000
  static double moduleVoltage(int a, int b) => ((a * 256) + b) / 1000.0;

  /// PID 0x04 — Calculated engine load (%)
  static double engineLoad(int a) => percent(a);

  /// PID 0x11 — Throttle position (%)
  static double throttle(int a) => percent(a);

  /// PID 0x2F — Fuel tank level (%)
  static double fuelLevel(int a) => percent(a);
}
