import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/pid_parser.dart';

/// Mode $01 PID request/response helpers over raw ISO-TP payloads (no ELM).
class ObdOnCan {
  ObdOnCan._();

  /// Build a Mode $01 request payload: `[0x01, pid]`.
  static List<int> mode01Request(int pid) => [0x01, pid & 0xFF];

  /// PIDs polled each telemetry cycle (same set as ELM path).
  static const List<int> pollPids = [
    0x0C, // RPM
    0x0D, // Speed
    0x05, // Coolant
    0x0F, // Intake
    0x11, // Throttle
    0x2F, // Fuel
    0x42, // Module voltage
  ];

  /// Parse a Mode $01 response payload (`41 <pid> <data…>`).
  ///
  /// Returns `(pid, dataBytes)` or `null` if not a valid Mode 01 reply.
  static (int pid, List<int> data)? parseMode01Response(List<int> payload) {
    if (payload.length < 3) return null;
    if (payload[0] != 0x41) return null;
    final pid = payload[1] & 0xFF;
    return (pid, List<int>.from(payload.sublist(2)));
  }

  /// Merge a Mode $01 PID response into [current] using [PidParser].
  static VehicleData applyPid(
    VehicleData current,
    int pid,
    List<int> data,
  ) {
    switch (pid) {
      case 0x0C:
        if (data.length < 2) return current;
        final rpm = PidParser.rpm(data[0], data[1]);
        final speed = current.speed ?? 0;
        return current.copyWith(
          rpm: rpm,
          gear: VehicleData.estimateGear(rpm, speed),
        );
      case 0x0D:
        if (data.isEmpty) return current;
        final speed = PidParser.speedKmh(data[0]);
        final rpm = current.rpm ?? 0;
        return current.copyWith(
          speed: speed,
          gear: VehicleData.estimateGear(rpm, speed),
        );
      case 0x05:
        if (data.isEmpty) return current;
        return current.copyWith(coolantTemp: PidParser.tempC(data[0]));
      case 0x0F:
        if (data.isEmpty) return current;
        return current.copyWith(intakeTemp: PidParser.tempC(data[0]));
      case 0x11:
        if (data.isEmpty) return current;
        return current.copyWith(throttlePosition: PidParser.throttle(data[0]));
      case 0x2F:
        if (data.isEmpty) return current;
        return current.copyWith(fuelLevel: PidParser.fuelLevel(data[0]));
      case 0x42:
        if (data.length < 2) return current;
        return current.copyWith(
          batteryVoltage: PidParser.moduleVoltage(data[0], data[1]),
        );
      default:
        return current;
    }
  }

  /// Parse [payload] as Mode 01 and merge into [current] when valid.
  static VehicleData applyResponse(VehicleData current, List<int> payload) {
    final parsed = parseMode01Response(payload);
    if (parsed == null) return current;
    final (pid, data) = parsed;
    return applyPid(current, pid, data);
  }
}
