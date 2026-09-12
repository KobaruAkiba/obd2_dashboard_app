/// Live vehicle telemetry from OBD-II (engineering units).
class VehicleData {
  final double? rpm;
  final double? speed;
  final double? coolantTemp;
  final double? intakeTemp;
  final double? throttlePosition;
  final double? batteryVoltage;
  final double fuelLevel;

  /// App-estimated gear: -1 = N, 0 = D (auto), 1–7 = manual.
  /// OBD-II Mode 01 does not provide gear position for most vehicles.
  final int gear;

  final bool engineReady;
  final String dtcs;
  final DateTime? freezeFrameTimestamp;
  final int? odometer;

  const VehicleData({
    this.rpm,
    this.speed,
    this.coolantTemp,
    this.intakeTemp,
    this.throttlePosition,
    this.batteryVoltage,
    this.gear = 0,
    this.engineReady = true,
    this.dtcs = '',
    this.freezeFrameTimestamp,
    this.fuelLevel = 100.0,
    this.odometer,
  });

  VehicleData copyWith({
    double? rpm,
    double? speed,
    double? coolantTemp,
    double? intakeTemp,
    double? throttlePosition,
    double? batteryVoltage,
    double? fuelLevel,
    int? gear,
    bool? engineReady,
    String? dtcs,
    DateTime? freezeFrameTimestamp,
    int? odometer,
  }) {
    return VehicleData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      coolantTemp: coolantTemp ?? this.coolantTemp,
      intakeTemp: intakeTemp ?? this.intakeTemp,
      throttlePosition: throttlePosition ?? this.throttlePosition,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      gear: gear ?? this.gear,
      engineReady: engineReady ?? this.engineReady,
      dtcs: dtcs ?? this.dtcs,
      freezeFrameTimestamp: freezeFrameTimestamp ?? this.freezeFrameTimestamp,
      odometer: odometer ?? this.odometer,
    );
  }

  String get gearLabel {
    switch (gear) {
      case -1:
        return 'N';
      case 0:
        return 'D';
      default:
        return gear.toString();
    }
  }

  String get statusSummary {
    final parts = <String>[];
    if (rpm != null) parts.add('RPM ${rpm!.toStringAsFixed(0)}');
    if (speed != null) parts.add('${speed!.toStringAsFixed(0)} km/h');
    parts.add('Gear $gearLabel');
    if (coolantTemp != null) {
      parts.add('Coolant ${coolantTemp!.toStringAsFixed(0)}°C');
    }
    if (dtcs.isNotEmpty) parts.add('DTC $dtcs');
    return parts.join(' · ');
  }

  /// Rough gear estimate for mock / demo only.
  static int estimateGear(double rpm, double speedKmh) {
    if (speedKmh < 1) return -1;
    if (speedKmh < 20) return 1;
    if (speedKmh < 40) return 2;
    if (speedKmh < 65) return 3;
    if (speedKmh < 90) return 4;
    if (speedKmh < 120) return 5;
    if (rpm > 4500) return 5;
    return 0;
  }
}
