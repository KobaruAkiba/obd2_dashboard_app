import 'dart:async';
import 'dart:math';

import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Realistic simulated OBD stream for UI development without hardware.
class MockObdService implements ObdService {
  MockObdService({this.cycleMs = 1500});

  final int cycleMs;
  final _dataController = StreamController<VehicleData>.broadcast();
  final _stateController = StreamController<ObdConnectionState>.broadcast();
  final _rng = Random();

  Timer? _timer;
  bool _disposed = false;
  int _tick = 0;

  @override
  String get displayName => ObdTransport.mock.displayName;

  @override
  ObdTransport get transport => ObdTransport.mock;

  @override
  Stream<VehicleData> get vehicleData => _dataController.stream;

  @override
  Stream<ObdConnectionState> get connectionState => _stateController.stream;

  @override
  Future<void> connect() async {
    if (_disposed) return;
    _stateController.add(ObdConnectionState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (_disposed) return;
    _stateController.add(ObdConnectionState.connected);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: cycleMs), (_) => _emit());
    _emit();
  }

  void _emit() {
    if (_disposed || _dataController.isClosed) return;
    _tick++;

    final phase = (_tick % 40) / 40.0;
    final cruising = phase < 0.7;
    final speed = cruising
        ? 45.0 + _rng.nextDouble() * 40
        : _rng.nextDouble() * 12;
    final rpm = speed < 5
        ? 850 + _rng.nextDouble() * 80
        : 1800 + speed * 28 + _rng.nextDouble() * 200;
    final throttle = speed < 5
        ? 5 + _rng.nextDouble() * 8
        : 20 + _rng.nextDouble() * 35;
    final coolant = 88 + _rng.nextDouble() * 10;
    final intake = 28 + _rng.nextDouble() * 14;
    final battery = 13.0 + _rng.nextDouble() * 0.8;
    final fuel = (72 - (_tick % 100) * 0.05).clamp(5.0, 100.0);

    String dtcs = '';
    if (_tick > 0 && _tick % 45 == 0) {
      const codes = ['P0127', 'P0133', 'P0420', 'P0171', 'P0300'];
      dtcs = codes[_rng.nextInt(codes.length)];
    }

    _dataController.add(
      VehicleData(
        rpm: rpm,
        speed: speed,
        coolantTemp: coolant,
        intakeTemp: intake,
        throttlePosition: throttle,
        batteryVoltage: battery,
        fuelLevel: fuel,
        gear: VehicleData.estimateGear(rpm, speed),
        dtcs: dtcs,
      ),
    );
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _timer = null;
    if (!_stateController.isClosed) {
      _stateController.add(ObdConnectionState.disconnected);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _dataController.close();
    _stateController.close();
  }
}
