import 'package:flutter_test/flutter_test.dart';
import 'package:obd_car_monitor/domain/obd/pid_parser.dart';

void main() {
  group('PidParser SAE J1979', () {
    test('RPM ((A*256)+B)/4', () {
      // 0x0C response bytes for 3000 rpm → A=0x2E, B=0xE0 → 12000/4=3000
      expect(PidParser.rpm(0x2E, 0xE0), 3000);
    });

    test('speed is raw km/h', () {
      expect(PidParser.speedKmh(90), 90);
    });

    test('temperature A-40', () {
      expect(PidParser.tempC(128), 88); // typical warm coolant
      expect(PidParser.tempC(40), 0);
    });

    test('percent A*100/255', () {
      expect(PidParser.throttle(255), closeTo(100, 0.01));
      expect(PidParser.fuelLevel(0), 0);
    });

    test('module voltage /1000', () {
      // 13.2 V → 13200 → A=0x33, B=0x90
      expect(PidParser.moduleVoltage(0x33, 0x90), closeTo(13.2, 0.01));
    });
  });
}
