import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_client.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_commands.dart';

import '../../helpers/fake_elm327_uart.dart';

void main() {
  group('Elm327Client over FakeElm327Uart', () {
    test('AT init then poll emits VehicleData', () async {
      final uart = FakeElm327Uart(rpmA: 0x2E, rpmB: 0xE0, speed: 90);
      addTearDown(uart.dispose);

      final client = Elm327Client(
        uart: uart,
        commandTimeout: const Duration(seconds: 2),
        pollInterval: const Duration(milliseconds: 5),
        resetSettle: Duration.zero,
      );
      addTearDown(client.dispose);

      final first = client.vehicleData.first.timeout(const Duration(seconds: 5));
      await client.start();

      final data = await first;
      expect(data.engineReady, isTrue);
      expect(data.rpm, 3000);
      expect(data.speed, 90);
      expect(data.coolantTemp, 88);
      expect(data.batteryVoltage, closeTo(13.2, 0.01));

      expect(uart.written.first, Elm327Commands.reset);
      expect(uart.written, containsAll(Elm327Commands.initSequence));
      expect(uart.written, contains(Elm327Commands.pidRpm));

      await client.stop();
    });

    test('command timeout surfaces TimeoutException', () async {
      final uart = FakeElm327Uart()..respond = false;
      addTearDown(uart.dispose);

      final client = Elm327Client(
        uart: uart,
        commandTimeout: const Duration(milliseconds: 80),
        resetSettle: Duration.zero,
      );
      addTearDown(client.dispose);

      await expectLater(client.start(), throwsA(isA<TimeoutException>()));
    });
  });
}
