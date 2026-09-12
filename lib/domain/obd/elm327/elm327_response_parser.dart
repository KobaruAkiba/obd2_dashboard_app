import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/pid_parser.dart';

/// Parsed Mode $01 PID payload bytes (after the `41 XX` header).
class Elm327PidResponse {
  const Elm327PidResponse({required this.pid, required this.data});

  /// PID number (e.g. `0x0C`).
  final int pid;

  /// Data bytes A, B, … following the PID in the response.
  final List<int> data;
}

/// Strips ELM chatter and turns Mode $01 replies into [VehicleData] fields.
class Elm327ResponseParser {
  Elm327ResponseParser._();

  static final _nonHex = RegExp(r'[^0-9A-Fa-f]');

  /// Normalize an ELM chunk: drop prompts, whitespace, and known status lines.
  static String sanitize(String raw) {
    var s = raw.replaceAll('>', ' ').replaceAll('\r', ' ').replaceAll('\n', ' ');
    s = s.toUpperCase();
    for (final noise in const [
      'SEARCHING...',
      'SEARCHING',
      'STOPPED',
      'BUS INIT',
      'BUSINIT',
      'OK',
    ]) {
      s = s.replaceAll(noise, ' ');
    }
    return s.trim();
  }

  /// True when the adapter reported no usable PID data.
  static bool isNoData(String raw) {
    final u = raw.toUpperCase();
    return u.contains('NO DATA') ||
        u.contains('UNABLE TO CONNECT') ||
        u.contains('CAN ERROR') ||
        u.contains('ERROR') ||
        u.contains('?');
  }

  /// Extract the first Mode $01 response (`41 <PID> <data…>`) from [raw].
  ///
  /// Tolerates spaces on/off and multi-frame hex glued together.
  static Elm327PidResponse? parseMode01(String raw) {
    if (isNoData(raw)) return null;

    final hex = sanitize(raw).replaceAll(_nonHex, '');
    if (hex.length < 6) return null;

    // Scan for 41 <pid> …
    for (var i = 0; i + 4 <= hex.length; i += 2) {
      final b0 = int.tryParse(hex.substring(i, i + 2), radix: 16);
      if (b0 != 0x41) continue;
      if (i + 4 > hex.length) break;
      final pid = int.tryParse(hex.substring(i + 2, i + 4), radix: 16);
      if (pid == null) continue;

      final data = <int>[];
      for (var j = i + 4; j + 2 <= hex.length; j += 2) {
        final b = int.tryParse(hex.substring(j, j + 2), radix: 16);
        if (b == null) break;
        // Next frame header starts a new response.
        if (b == 0x41 && data.isNotEmpty) break;
        data.add(b);
      }
      if (data.isEmpty) continue;
      return Elm327PidResponse(pid: pid, data: data);
    }
    return null;
  }

  /// Merge a Mode $01 PID response into [current] using [PidParser].
  static VehicleData applyPid(VehicleData current, Elm327PidResponse response) {
    final d = response.data;
    switch (response.pid) {
      case 0x0C:
        if (d.length < 2) return current;
        final rpm = PidParser.rpm(d[0], d[1]);
        final speed = current.speed ?? 0;
        return current.copyWith(
          rpm: rpm,
          gear: VehicleData.estimateGear(rpm, speed),
        );
      case 0x0D:
        if (d.isEmpty) return current;
        final speed = PidParser.speedKmh(d[0]);
        final rpm = current.rpm ?? 0;
        return current.copyWith(
          speed: speed,
          gear: VehicleData.estimateGear(rpm, speed),
        );
      case 0x05:
        if (d.isEmpty) return current;
        return current.copyWith(coolantTemp: PidParser.tempC(d[0]));
      case 0x0F:
        if (d.isEmpty) return current;
        return current.copyWith(intakeTemp: PidParser.tempC(d[0]));
      case 0x11:
        if (d.isEmpty) return current;
        return current.copyWith(throttlePosition: PidParser.throttle(d[0]));
      case 0x2F:
        if (d.isEmpty) return current;
        return current.copyWith(fuelLevel: PidParser.fuelLevel(d[0]));
      case 0x42:
        if (d.length < 2) return current;
        return current.copyWith(
          batteryVoltage: PidParser.moduleVoltage(d[0], d[1]),
        );
      default:
        return current;
    }
  }

  /// Apply a raw ELM reply for an expected [pid] (e.g. `0x0C`) if present.
  static VehicleData applyRaw(
    VehicleData current,
    String raw, {
    int? expectedPid,
  }) {
    final parsed = parseMode01(raw);
    if (parsed == null) return current;
    if (expectedPid != null && parsed.pid != expectedPid) return current;
    return applyPid(current, parsed);
  }
}
