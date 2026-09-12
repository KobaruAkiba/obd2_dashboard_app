/// ELM327 AT / OBD-II Mode $01 command strings (CR terminated by the client).
class Elm327Commands {
  Elm327Commands._();

  // --- Adapter init (order matters) ---
  static const reset = 'ATZ';
  static const echoOff = 'ATE0';
  static const linefeedsOff = 'ATL0';
  static const spacesOff = 'ATS0';
  static const headersOff = 'ATH0';
  static const protocolAuto = 'ATSP0';

  /// Full AT init sequence after physical link is up.
  static const List<String> initSequence = [
    reset,
    echoOff,
    linefeedsOff,
    spacesOff,
    headersOff,
    protocolAuto,
  ];

  // --- Mode $01 PIDs used by [PidParser] ---
  static const pidRpm = '010C';
  static const pidSpeed = '010D';
  static const pidCoolant = '0105';
  static const pidIntake = '010F';
  static const pidThrottle = '0111';
  static const pidFuelLevel = '012F';
  static const pidModuleVoltage = '0142';

  /// Poll order for one telemetry frame.
  static const List<String> pollPids = [
    pidRpm,
    pidSpeed,
    pidCoolant,
    pidIntake,
    pidThrottle,
    pidFuelLevel,
    pidModuleVoltage,
  ];
}
