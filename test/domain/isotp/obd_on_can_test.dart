import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/domain/isotp/obd_on_can.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';

void main() {
  group('ObdOnCan', () {
    test('mode01Request builds Mode 01 + PID', () {
      expect(ObdOnCan.mode01Request(0x0C), [0x01, 0x0C]);
    });

    test('parseMode01Response extracts pid and data', () {
      final parsed = ObdOnCan.parseMode01Response([0x41, 0x0C, 0x2E, 0xE0]);
      expect(parsed, isNotNull);
      expect(parsed!.$1, 0x0C);
      expect(parsed.$2, [0x2E, 0xE0]);
    });

    test('applyResponse merges RPM via PidParser', () {
      var data = const VehicleData();
      data = ObdOnCan.applyResponse(data, [0x41, 0x0C, 0x2E, 0xE0]);
      expect(data.rpm, 3000);

      data = ObdOnCan.applyResponse(data, [0x41, 0x0D, 90]);
      expect(data.speed, 90);
      expect(data.gear, VehicleData.estimateGear(3000, 90));
    });

    test('applyPid covers coolant throttle fuel voltage', () {
      var data = const VehicleData();
      data = ObdOnCan.applyPid(data, 0x05, [128]);
      expect(data.coolantTemp, 88);

      data = ObdOnCan.applyPid(data, 0x11, [255]);
      expect(data.throttlePosition, closeTo(100, 0.01));

      data = ObdOnCan.applyPid(data, 0x2F, [0]);
      expect(data.fuelLevel, 0);

      data = ObdOnCan.applyPid(data, 0x42, [0x33, 0x90]);
      expect(data.batteryVoltage, closeTo(13.2, 0.01));
    });

    test('ignores non Mode 01 payload', () {
      const base = VehicleData(rpm: 1000);
      final out = ObdOnCan.applyResponse(base, [0x7F, 0x01, 0x11]);
      expect(out.rpm, 1000);
    });
  });
}
