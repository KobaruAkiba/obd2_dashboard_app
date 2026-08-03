import 'dart:async';
import '../models/vehicle_data.dart';

/// ODB mock service for Windows desktop testing
/// Provides realistic mock data to avoid blocking when no physical CAN adapter is connected
class WindowsMockOdbService {
  final StreamController<VehicleData> _controller =
      StreamController<VehicleData>.broadcast();
  Timer? _simulationTimer;

  /// Connect and start streaming mock data automatically
  void connect({
    double? targetRpm,
    double? targetSpeed,
    double? targetTemp,
    int cycleDuration = 2500, // ms between updates (faster for responsive UI)
  }) {
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: cycleDuration),
      (timer) async {
        // Simulate realistic OBDII data with some noise
        final now = DateTime.now();
        final randomSeed = now.microsecond % 1000;

        // RPM: Engine idle ~850-950, varies slightly
        double rpm = targetRpm ?? (880.0 + ((randomSeed % 30).toDouble()));

        // Speed: Simulates realistic driving (0-120 km/h)
        double speed = targetSpeed ?? _generateRealisticSpeed(randomSeed);

        // Coolant temperature: Warm engine ~90-100°C
        double coolantTemp = targetTemp ?? (93.0 + ((randomSeed % 8).toDouble() - 4));

        // Intake air temp: Usually 20-50°C ambient
        int intakeRaw = 35 + ((randomSeed % 12) - 6);

        // Throttle position: 0-100% based on "engine load"
        double throttle = _generateThrottle(randomSeed);

        // Battery voltage: ~12.6V when running (14.4V at fast charge)
        double batteryRaw = 13.0 + ((randomSeed % 5).toDouble() / 10);

        final vehicleData = VehicleData(
          rpm: (rpm * 256 / 255), // Scale to hex byte range
          speed: speed,
          coolantTemp: (coolantTemp - 40), // Adjust for PID scale
          intakeTemp: ((intakeRaw + 40) % 127).toDouble(),
          throttlePosition: throttle,
          batteryVoltage: batteryRaw,
        );

        if (_controller.hasListener) {
          _controller.add(vehicleData);
        }
      },
    );
  }

  /// Disconnect and stop streaming
  void disconnect() {
    _controller.close();
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  Stream<VehicleData> get stream => _controller.stream;



  /// Generate realistic speed variations
  double _generateRealisticSpeed(int randomSeed) {
    // Simulate acceleration and deceleration phases
    final baseSpeed = 40.0 + ((randomSeed % 60).toDouble());
    
    // Occasionally simulate stop/traffic (speed drops to 0-10 km/h)
    if (randomSeed % 5 == 0) {
      return (randomSeed % 11).toDouble();
    }
    
    // Simulate highway cruising
    if (randomSeed % 7 == 0) {
      return (95.0 + ((randomSeed % 20).toDouble() - 10));
    }
    
    return baseSpeed;
  }

  /// Generate realistic throttle position based on speed/load
  double _generateThrottle(int randomSeed) {
    // Higher speed = higher throttle (open loop driving)
    final minThrottle = 5.0 + ((randomSeed % 10).toDouble() / 2);
    
    // Simulate occasional deceleration (foot off gas pedal)
    if (randomSeed % 8 == 7) {
      return (randomSeed % 21).toDouble();
    }
    
    // Normal driving: throttle opens progressively
    return minThrottle + ((randomSeed % 40).toDouble());
  }

  /// Simulates detecting a Diagnostic Trouble Code occasionally
  void simulateDTCEvent() async {
    await Future<Duration>.delayed(const Duration(milliseconds: 500));

    // Only inject DTCs occasionally (every ~30 seconds of simulation)
    final mockData = VehicleData(
      rpm: 890,
      speed: 55,
      coolantTemp: 92,
      throttlePosition: 42,
      batteryVoltage: 13.1,
      dtcs: _generateDTCCode(),
    );

    if (_controller.hasListener) {
      _controller.add(mockData);
    }
  }

  /// Generates realistic DTC codes
  String _generateDTCCode() {
    final dtcs = ['P0127', 'P0133', 'P0420', 'P0171', 'P0300'];
    return dtcs[DateTime.now().millisecond % dtcs.length];
  }

  /// Get current stream status (for debugging)
  String getStatus() {
    if (_simulationTimer != null && _controller.hasListener) {
      return 'Mock Service Connected - Stream Active';
    }
    return 'Mock Service Disconnected or No Listeners';
  }
}
