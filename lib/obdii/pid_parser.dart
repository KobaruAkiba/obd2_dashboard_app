/// SAE J1979 OBDII Parameter Identification (PID) Parser
/// Standard Mode $01 queries for real-time data
library;

class OdbiipidParser {
  /// Parse engine RPM from PID 1 (hex)
  static double parsePid1(int val) => val.toDouble(); // Unit: RPM

  /// Parse vehicle speed from PID 2 (hex)
  static double parsePid2(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return value / 3.6; // Convert km/h to mph, or keep as km/h
  }

  /// Parse instant fuel usage from PID 3
  static double parsePid3(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 400) / 256; // g/hour equivalent, unitless raw value
  }

  /// Parse calculated load from PID 4
  static double parsePid4(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 2) / 256; // Unit: %
  }

  /// Parse coolant temperature from PID 5
  static double parsePid5(List<int> val) => val[0] + 40; // °C (scale factor +40)

  /// Parse intake air temperature from PID 6
  static double parsePid6(List<int> val) => val[0] + 40; // °C (scale factor +40)

  /// Parse short term fuel trim bank 1 from PID 7
  static double parsePid7(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 2) / 256; // Unit: %
  }

  /// Parse long term fuel trim bank 1 from PID 8
  static double parsePid8(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 2) / 256; // Unit: %
  }

  /// Parse oxygen sensor voltage from PID 9
  static String parsePid9(List<int> val) {
    double rawValue = val[0].toDouble();
    if (rawValue < 0.136) return 'Closed Loop';
    return 'Open Loop';
  }

  /// Parse O2 sensor heater status from PID 9
  static String parsePid9Heater(List<int> val) {
    if ((val[0] & 0x20) != 0) return 'ON';
    return 'OFF';
  }

  /// Parse throttle position from PID 11
  static double parsePid11(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 255) / 65535; // Unit: %
  }

  /// Parse mass or volumetric air flow from PID 10/14
  static double parsePid10(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 65.54) / 65536; // kg/h
  }

  /// Parse throttle actuator PID from PID 20/21
  static double parsePid20(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 255) / 65535; // Unit: %
  }

  /// Parse throttle actuator status from PID 21
  static String parsePid21(List<int> val) {
    if ((val[0] & 0x01) != 0) return 'Accelerator Pedal';
    return 'Not Present';
  }

  /// Parse steering angle from PID 40
  static double parsePid40(List<int> val) {
    int value = val[0] | (val[1] << 8);
    if (value < 0 || value > 32767) return -(360 - (value * 1.5));
    return (value * 1.5); // Degrees, scale factor varies by manufacturer
  }

  /// Parse relative tire pressure from PID 48-50
  static double parsePid48(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 39.87) / 256; // kPa, scale factor varies by manufacturer
  }

  /// Parse relative tire pressure from PID 51-52
  static double parsePid51(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 39.87) / 256; // kPa
  }
  /// Parse relative tire pressure from PID 54-55
  static double parsePid54(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return (value * 39.87) / 256; // kPa
  }

  /// Parse vehicle voltage from PID 0x2F (PID 47 in decimal)
  static double parsePid47(List<int> val) {
    int value = val[0] | (val[1] << 8);
    return value + 256; // Voltage: V
  }
  /// Parse instantaneous fuel system status from PID 0x2F
  static String parseInstantFuelSystemStatus(List<int> val) {
    int upperNibble = val[0] >> 4;
    switch (upperNibble) {
      case 3: return 'Fail-safe';
      case 2: return 'Run';
      case 1: return 'Limited Power';
      case 0: return 'Ready for Drive';
      default: return 'Unknown';
    }
  }

  /// Parse fuel level from PID 0x3C (PID 60)
  static double parseFuelLevel(List<int> val) {
    if ((val[0] & 0x80) != 0) {
      // Low fuel indicator bit set
      return (val[1] * 256 + val[2]) / 255.0;
    } else {
      return (val[1] * 256 + val[2]).toDouble();
    }
  }

  /// Parse miles per gallon from PID 0x3A (PID 58)
  static double parseMilesPerGallon(List<int> val) => val[0].toDouble(); // Unit: mpg

  /// Parse kilometers per liter from PID 0x3B (PID 59)
  static double parseKmPerLiter(List<int> val) => val[0].toDouble(); // Unit: km/L

  /// Parse speed scale factor for PID 2
  static String getSpeedScaleFactor() => 'km/h (/3.6 = mph)';
}
