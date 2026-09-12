import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/data/adapters/can/can_ring_buffer.dart';
import 'package:odb_dashboard/data/adapters/can/can_frame.dart';
import 'package:odb_dashboard/data/adapters/can/fake/fake_can_driver.dart';
import 'package:odb_dashboard/data/adapters/can/can_obd_session.dart';
import 'package:odb_dashboard/domain/isotp/isotp_types.dart';

void main() {
  group('CanRingBuffer', () {
    test('drop-old increments droppedFrames', () {
      final ring = CanRingBuffer(2);
      ring.push(const CanFrame(id: 1, data: [1]));
      ring.push(const CanFrame(id: 2, data: [2]));
      expect(ring.isFull, isTrue);
      ring.push(const CanFrame(id: 3, data: [3]));
      expect(ring.droppedFrames, 1);
      expect(ring.pop()!.id, 2);
      expect(ring.pop()!.id, 3);
    });
  });

  group('CanObdSession + FakeCanDriver', () {
    test('polls Mode 01 and emits RPM', () async {
      final driver = FakeCanDriver(autoRespondMode01: true);
      await driver.open();

      final session = CanObdSession(
        driver: driver,
        pids: const [0x0C],
        pollInterval: const Duration(milliseconds: 5),
      );

      final first = session.vehicleData.first.timeout(
        const Duration(seconds: 3),
      );

      await session.start();
      final data = await first;

      expect(data.rpm, 3000);
      expect(driver.written, isNotEmpty);
      expect(driver.written.first.id, IsotpAddress.request);

      await session.stop();
      session.dispose();
      await driver.close();
    });
  });
}
