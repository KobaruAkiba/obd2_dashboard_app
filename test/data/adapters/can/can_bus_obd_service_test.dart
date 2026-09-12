import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/data/adapters/can/can_bus_obd_service.dart';
import 'package:odb_dashboard/data/adapters/can/fake/fake_can_driver.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

void main() {
  group('CanBusObdService', () {
    test('transport is canBus and accepts injected driver', () async {
      final driver = FakeCanDriver(autoRespondMode01: true);
      final service = CanBusObdService(
        driver: driver,
        emitInterval: const Duration(milliseconds: 50),
      );

      expect(service.transport, ObdTransport.canBus);
      expect(service.displayName, 'CAN bus');

      final states = <ObdConnectionState>[];
      final sub = service.connectionState.listen(states.add);

      await service.connect();
      // Broadcast stream events are async; flush before asserting.
      await Future<void>.delayed(Duration.zero);

      expect(states, contains(ObdConnectionState.connected));
      expect(driver.isOpen, isTrue);

      await service.disconnect();
      await sub.cancel();
      service.dispose();
    });

    test('vehicleData capped at ~20Hz; latest value wins', () async {
      final service = CanBusObdService(
        driver: FakeCanDriver(),
        emitInterval: const Duration(milliseconds: 50),
      );

      final emitted = <VehicleData>[];
      final sub = service.vehicleData.listen(emitted.add);

      // Burst ~100 updates in ~100ms (far above 20 Hz). No connect()/DLL needed.
      for (var i = 0; i < 100; i++) {
        service.debugPushVehicleData(VehicleData(rpm: i.toDouble()));
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      // Allow trailing coalesced emit.
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(emitted, isNotEmpty);
      // Over ~180ms wall, 20Hz ⇒ ≤ ~5–6; allow headroom for timer jitter.
      expect(emitted.length, lessThanOrEqualTo(10));
      expect(emitted.last.rpm, 99);
      expect(service.latestSnapshot.rpm, 99);
      expect(service.droppedStreamUpdates, greaterThan(0));

      await sub.cancel();
      service.dispose();
    });
  });
}
