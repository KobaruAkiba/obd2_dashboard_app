import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_response_parser.dart';

void main() {
  group('Elm327ResponseParser', () {
    test('sanitize strips prompt and status noise', () {
      expect(
        Elm327ResponseParser.sanitize('SEARCHING...\r41 0C 1A F8\r\n>'),
        '41 0C 1A F8',
      );
    });

    test('parseMode01 with spaces', () {
      final r = Elm327ResponseParser.parseMode01('41 0C 2E E0\r>');
      expect(r, isNotNull);
      expect(r!.pid, 0x0C);
      expect(r.data, [0x2E, 0xE0]);
    });

    test('parseMode01 without spaces', () {
      final r = Elm327ResponseParser.parseMode01('410D5A');
      expect(r, isNotNull);
      expect(r!.pid, 0x0D);
      expect(r.data, [0x5A]);
    });

    test('parseMode01 returns null on NO DATA', () {
      expect(Elm327ResponseParser.parseMode01('NO DATA\r>'), isNull);
      expect(Elm327ResponseParser.isNoData('UNABLE TO CONNECT'), isTrue);
    });

    test('applyPid builds VehicleData via PidParser', () {
      var data = const VehicleData();
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x0C, data: [0x2E, 0xE0]),
      );
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x0D, data: [90]),
      );
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x05, data: [128]),
      );
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x0F, data: [70]),
      );
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x11, data: [128]),
      );
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x2F, data: [0]),
      );
      data = Elm327ResponseParser.applyPid(
        data,
        const Elm327PidResponse(pid: 0x42, data: [0x33, 0x90]),
      );

      expect(data.rpm, 3000);
      expect(data.speed, 90);
      expect(data.coolantTemp, 88);
      expect(data.intakeTemp, 30);
      expect(data.throttlePosition, closeTo(50.196, 0.01));
      expect(data.fuelLevel, 0);
      expect(data.batteryVoltage, closeTo(13.2, 0.01));
      expect(data.gear, VehicleData.estimateGear(3000, 90));
    });

    test('applyRaw ignores mismatched expected PID', () {
      const base = VehicleData(rpm: 1000);
      final next = Elm327ResponseParser.applyRaw(
        base,
        '410D5A',
        expectedPid: 0x0C,
      );
      expect(next.rpm, 1000);
      expect(next.speed, isNull);
    });
  });
}
