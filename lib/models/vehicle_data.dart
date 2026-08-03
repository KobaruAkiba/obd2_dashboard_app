import 'package:flutter/material.dart';
import '../obdii/pid_parser.dart';

class VehicleData {
  final double? rpm;
  final double? speed;
  final double? coolantTemp;
  final double? intakeTemp;
  final double? throttlePosition;
  final double? batteryVoltage;
  final int gear; // Gear position: -1=Neutral, 0=Drive, 1-7=manual gears
  final bool engineReady;
  final String dtcs;
  final DateTime freezeFrameTimestamp = DateTime.now();
  final double fuelLevel;
  final int? odometer;

  VehicleData({
    this.rpm,
    this.speed,
    this.coolantTemp,
    this.intakeTemp,
    this.throttlePosition,
    this.batteryVoltage,
    this.gear = 0, // Default to Drive
    this.engineReady = true,
    this.dtcs = '',
    // this.freezeFrameTimestamp = DateTime.now(),
    this.fuelLevel = 100.0,
    this.odometer,
  });

  static VehicleData fromCanBytes(List<int> canData) {
    if (canData.isEmpty) return VehicleData();

    return VehicleData(
      rpm: OdbiipidParser.parsePid1(canData[0]),
      speed: OdbiipidParser.parsePid2([canData[1], canData[2]]),
      coolantTemp: OdbiipidParser.parsePid5([canData[3], canData[4]]),
      intakeTemp: OdbiipidParser.parsePid6([canData[5], canData[6]]),
      throttlePosition: OdbiipidParser.parsePid11([canData[7], canData[8]]),
      batteryVoltage: OdbiipidParser.parsePid47(canData),
      gear: 0, // Default to Drive - must track separately
    );
  }

  String getStatusSummary() {
    final List<String> components = [];

    if (rpm != null) components.add('RPM: ${rpm!.toStringAsFixed(0)}');
    if (speed != null) {
      components.add('Speed: ${speed!.toStringAsFixed(1)} km/h');
    }

    final gearStr = _getGearDisplay(gear);
    components.add('Gear: $gearStr');

    if (coolantTemp != null) {
      components.add('Coolant: ${coolantTemp!.toStringAsFixed(0)}°C');
    }
    if (intakeTemp != null) {
      components.add('Intake: ${intakeTemp!.toStringAsFixed(0)}°C');
    }
    if (throttlePosition != null) {
      components.add('Throttle: ${throttlePosition!.toStringAsFixed(1)}%');
    }

    if (dtcs.isNotEmpty) {
      components.add('DTCs Detected: $dtcs');
    }

    return components.join('; ');
  }

  String _getGearDisplay(int gear) {
    switch (gear) {
      case -1:
        return 'N'; // Neutral
      case 0:
        return 'D'; // Drive
      default:
        return gear.toString(); // Manual gears
    }
  }
}

class DtcEntry {
  final String code;
  final String description;
  final int severity;
  final DateTime detectedAt = DateTime.now();

  DtcEntry({
    required this.code,
    required this.description,
    required this.severity,
    // this.detectedAt = DateTime.now(),
  });

  Color getSeverityColor() => severity == 1
      ? Colors.orange
      : severity == 2
          ? Colors.red
          : Colors.black;
}
