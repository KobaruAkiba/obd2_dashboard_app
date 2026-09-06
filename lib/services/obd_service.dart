import '../models/vehicle_data.dart';

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

  Stream<VehicleData> get vehicleData;
  Stream<ObdConnectionState> get connectionState;

  Future<void> connect();
  Future<void> disconnect();
  void dispose();
}
