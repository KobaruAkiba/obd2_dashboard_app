import 'dart:async';
import '../models/vehicle_data.dart';

/// Mock Bluetooth Serial Service for testing without physical dongle
class MockBluetoothSerialService {
  final StreamController<VehicleData> _controller =
      StreamController<VehicleData>.broadcast();
  Timer? _simulationTimer;

  /// Disconnect and cancel any running simulation
  void disconnect() {
    _controller.close();
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Simulates receiving OBDII data stream (Mode $01 - Real-time data)
  Stream<VehicleData> parseIncomingData() {
    return _controller.stream;
  }

  /// Mock vehicle data generator with realistic values
  void simulateVehicleData({
    double? targetRpm,
    double? targetSpeed,
    double? targetTemp,
    int cycleDuration = 3000, // ms between updates
  }) {
    Timer.periodic(Duration(milliseconds: cycleDuration), (timer) async {
      await Future<dynamic>.delayed(
          const Duration(milliseconds: 500)); // Simulate network latency

      // Generate realistic OBDII data with some noise
      final random = DateTime.now().millisecondsSinceEpoch % 1000;

      // RPM: Engine idle ~800-1000, increases under load
      double rpm = targetRpm ?? (850 + (random % 30));

      // Speed: Can vary from 0 to highway speeds
      double speed = targetSpeed ?? (20.0 + (random % 40));

      // Coolant temperature: Should be ~87-95°C when warm
      double coolantTemp =
          targetTemp ?? (89.0 + ((random % 10).toDouble() - 5));

      // Intake air temp: Usually 20-40°C ambient
      int intakeRaw = 30 + ((random % 15) - 7); // Will add offset in parser

      // Throttle position: 0-100% based on load
      double throttle = (random % 80).toDouble();

      // Battery voltage: 12.6V when running, slight variations
      double batteryRaw = 13 + (random % 4);

      final vehicleData = VehicleData(
        rpm: (rpm * 256 / 255), // Convert to hex byte range
        speed: (speed * 256 / 255), // Simulated reading scaling
        coolantTemp: (coolantTemp - 40), // Adjust for PID scale
        intakeTemp: ((intakeRaw + 40) % 127), // Keep in valid range
        throttlePosition: throttle,
        batteryVoltage: batteryRaw,
      );

      if (_controller.hasListener) {
        _controller.add(vehicleData);
      }

      // Simulate occasional DTC codes (every ~30 seconds)
      if (cycleDuration % 30 == random && random > 2800) {
        simulateDTCEvent();
      }
    });
  }

  /// Simulates detecting a Diagnostic Trouble Code
  void simulateDTCEvent() async {
    await Future<Duration>.delayed(const Duration(milliseconds: 500));

    final dtcs = ['P0127', 'P0133', 'P0420'][DateTime.now().millisecond % 3];

    final mockData = VehicleData(
      rpm: 900,
      speed: 60,
      coolantTemp: 90,
      throttlePosition: 45,
      batteryVoltage: 13,
      dtcs: "P$dtcs: Fuel System Malfunction",
    );

    if (_controller.hasListener) {
      _controller.add(mockData);
    }
  }
}
