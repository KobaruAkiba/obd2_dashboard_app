import 'package:obd_car_monitor/domain/models/vehicle_data.dart';
import 'package:obd_car_monitor/domain/obd/obd_transport.dart';

enum ObdConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Contract for all OBD data sources (mock today, real adapters later).
abstract class ObdService {
  /// Human-readable label for the UI (e.g. "Mock", "Bluetooth serial").
  String get displayName;

  /// Concrete transport — used for UI mode mapping without string matching.
  ObdTransport get transport;

  Stream<VehicleData> get vehicleData;
  Stream<ObdConnectionState> get connectionState;

  Future<void> connect();
  Future<void> disconnect();
  void dispose();
}
