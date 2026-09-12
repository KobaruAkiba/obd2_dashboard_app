import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/presentation/dashboard/dashboard_controller.dart';

void main() {
  group('DashboardController UI throttle', () {
    test('keeps latest data and drops excess notifies at 20Hz', () async {
      final controller = DashboardController(
        uiNotifyInterval: const Duration(milliseconds: 50),
      );

      var notifies = 0;
      controller.addListener(() => notifies++);

      for (var i = 0; i < 40; i++) {
        controller.debugApplyVehicleData(VehicleData(rpm: i.toDouble()));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.data.rpm, 39);
      expect(controller.droppedUiUpdates, greaterThan(0));
      // 40 samples over ~200ms + trailing; at 20Hz expect far fewer notifies.
      expect(notifies, lessThan(40));
      expect(notifies, lessThanOrEqualTo(12));

      controller.dispose();
    });
  });
}
