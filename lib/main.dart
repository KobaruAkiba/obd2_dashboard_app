import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:obd_car_monitor/utils/debug.dart';
import 'models/vehicle_data.dart';
import 'services/service_router.dart';
import 'services/windows_mock_odb_service.dart';
import 'services/windows_bluetooth_serial_service.dart';
import 'services/mock_bluetooth_serial_service.dart';
import 'widgets/dashboard_layouts/tresla_style_dashboard.dart';

void main() {
  runApp(const OBDApp());
}

class OBDApp extends StatefulWidget {
  const OBDApp({super.key});

  @override
  State<OBDApp> createState() => _OBDAppState();
}

class _OBDAppState extends State<OBDApp> {
  VehicleData? currentData;
  int currentGear = 0; // Track gear separately (OBD-II doesn't provide it)
  DateTime? lastUpdate;
  StreamSubscription<dynamic>? _dataSubscription;
  Duration connectionDuration = Duration.zero;
  String connectionStatus = 'Disconnected';
  Map<String, dynamic>? serviceInfo;

  /// Track connection attempt timer for fallback mock button (debug mode only)
  Timer? _connectionTimer;
  DateTime? _connectionStartTime;
  bool _isSearchingForHardware = false;
  bool _mockDataEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }

  /// Initialize connection based on platform and hardware availability
  void _initializeConnection() async {
    final serviceType = ServiceRouter.forcedServiceType ?? 'auto';
    final isWindows = defaultTargetPlatform == TargetPlatform.windows;
    final isMockMode = !ServiceRouter.useRealHardware;
    final wantsBluetooth =
        serviceType == ServiceRouter.windowsBtSerialService ||
            Platform.environment['USE_BLUETOOTH_OBD'] == 'true';

    if (wantsBluetooth) {
      final bluetoothService = WindowsBluetoothSerialService();
      bluetoothService.connect(
        deviceId: 'Auto-Scan',
        baudRate: 115200,
        serviceClassId: null,
      );
      _setupStreamSubscription(bluetoothService.stream);

      setState(() {
        connectionStatus = 'Bluetooth Serial Connected';
      });
    } else if (isMockMode) {
      // Use mock data for Windows development/testing
      if (isWindows) {
        final mockService = WindowsMockOdbService();
        mockService.connect(cycleDuration: 2000);
        _setupStreamSubscription(mockService.stream);

        setState(() {
          connectionStatus = 'Mock Mode';
        });
      } else {
        // Mobile mock service for testing on other platforms
        final mockService = MockBluetoothSerialService();
        final stream = mockService.parseIncomingData();
        _setupStreamSubscription(stream);

        setState(() {
          connectionStatus = 'Mock BLE Mode';
        });
      }
    } else {
      // Real hardware mode - will show connection UI
      setState(() {
        connectionStatus = 'Connecting...';
      });

      // Start timeout timer for fallback mock button in debug mode
      if (ServiceRouter.isDebugMode) {
        _startConnectionTimeoutTimer();
      }

      try {
        final service = await ServiceRouter.createService();
        await service.connect();
        _setupStreamSubscription(service.stream);
        if (!mounted) return;
        setState(() {
          connectionStatus = 'Connected - Real Hardware';
        });
      } catch (e) {
        // Silently fail and fallback to mock
        setState(() {
          connectionStatus = 'Connection Failed';
        });

        // Auto-fallback to mock for development convenience
        if (!mounted) return;
        showFallbackMockData();
      }
    }

    // Always get service info for debug UI
    _loadServiceInfo();
  }

  /// Load service status information
  Future<void> _loadServiceInfo() async {
    serviceInfo = ServiceRouter.getServiceStatus();
  }

  /// Setup stream subscription with error handling
  void _setupStreamSubscription(dynamic stream) {
    _dataSubscription = stream.listen(
      (dynamic event) {
        if (event is Map<String, dynamic>) {
          // Handle legacy real service format
          if ((event['type'] as String?) == 'HEARTBEAT') {
            final timestampStr = event['timestamp'] as String?;
            if (timestampStr != null) {
              final ts = DateTime.tryParse(timestampStr);
              if (ts != null) {
                connectionDuration = DateTime.now().difference(ts);
              }
            }
            if (mounted && connectionStatus.contains('Mock')) {
              setState(() {}); // Trigger rebuild for mock mode updates
            }
          } else if ((event['type'] as String?) == 'DISCONNECTED' ||
              (event['type'] as String?) == 'TX_FRAME') {
            final data = VehicleData(
              rpm: _parseValue(event, 'rpm'),
              speed: _parseValue(event, 'speed'),
              coolantTemp: _parseValue(event, 'temp'),
              intakeTemp: _parseValue(event, 'intake'),
              throttlePosition: _parseValue(event, 'throttle'),
              batteryVoltage: _parseValue(event, 'voltage'),
              dtcs: event['dtcs'].toString(),
            );

            setState(() {
              currentData = data;
              lastUpdate = DateTime.now();
            });
          } else if ((event['type'] as String?) == 'ERROR') {
            printIfDebug('[STREAM] Error: ${event['message']}');
          }
        } else if (event is VehicleData) {
          // Handle VehicleData events directly (mock services)
          final updatedEvent = VehicleData(
            rpm: event.rpm,
            speed: event.speed,
            coolantTemp: event.coolantTemp,
            intakeTemp: event.intakeTemp,
            throttlePosition: event.throttlePosition,
            batteryVoltage: event.batteryVoltage,
            gear: currentGear, // Keep tracking gear state
            dtcs: event.dtcs,
          );
          setState(() {
            currentData = updatedEvent;
            lastUpdate = DateTime.now();
          });
        }
      },
      onError: (dynamic error, stackTrace) {
        printIfDebug('[STREAM] Error: $error');
      },
      onDone: () {
        printIfDebug('[STREAM] Stream completed');
      },
    ) as StreamSubscription<dynamic>;
  }

  /// Parse vehicle data from event stream
  double? _parseValue(Map<String, dynamic> event, String key) {
    if (event['vehicleData'] != null) {
      final vd = event['vehicleData'] as Map;
      return vd[key] as double?;
    }
    return null;
  }

  /// Show fallback mock data when connection fails
  void showFallbackMockData() async {
    await Future<void>.delayed(Duration.zero);

    final mockService = WindowsMockOdbService();
    mockService.connect(cycleDuration: 2000);

    _setupStreamSubscription(mockService.stream);

    if (!mounted) return;

    setState(() {
      connectionStatus = 'Fallback to Mock Data';
    });
  }

  /// Simulate vehicle data for testing (when no hardware available)
  VehicleData simulateVehicleData() {
    final now = DateTime.now();
    final randomSeed = now.microsecond % 1000;

    return VehicleData(
      rpm: 880.0 + ((randomSeed % 30).toDouble()),
      speed: 65.0 + ((randomSeed % 40).toDouble()),
      coolantTemp: 92.0 + ((randomSeed % 8).toDouble() - 4),
      intakeTemp: (35 + ((randomSeed % 12) - 6)).toDouble(),
      throttlePosition: 42.0,
      batteryVoltage: 13.1,
      gear: 0, // Default to Drive for simulation
      dtcs: '',
    );
  }

  /// Start timer to show mock data fallback button after searching for hardware
  void _startConnectionTimeoutTimer() {
    // Cancel any existing timer first
    _connectionTimer?.cancel();

    if (!_mockDataEnabled) {
      _connectionStartTime = DateTime.now();
      // Show fallback option after 5 seconds of no data received
      const timeoutDuration = Duration(seconds: 5);
      _connectionTimer = Timer(timeoutDuration, () {
        if (mounted && !_mockDataEnabled && _isSearchingForHardware) {
          setState(() {
            _isSearchingForHardware = false;
          });
        }
      });
    }
  }

  /// Activate mock data mode when button is clicked (debug only)
  Future<void> _activateMockData() async {
    if (!mounted || _mockDataEnabled) return;

    printIfDebug('[DEBUG] Activating mock data mode from debug UI');

    setState(() {
      _mockDataEnabled = true;
    });

    // Cancel hardware search timer
    _connectionTimer?.cancel();
    _connectionStartTime = null;

    // Create and connect to mock service
    final mockService = WindowsMockOdbService();
    mockService.connect(cycleDuration: 2000);
    _setupStreamSubscription(mockService.stream);

    if (!mounted) return;

    setState(() {
      connectionStatus = 'Mock Data (Debug Mode)';
    });
  }

  /// Calculate time searching for hardware in seconds
  double _getSearchTime() {
    if (_connectionStartTime == null) return 0;
    return (DateTime.now().millisecond - _connectionStartTime!.millisecond) /
        1000.0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OBDHome(
        data: currentData ?? VehicleData(),
        lastUpdate: lastUpdate,
        connectionStatus: connectionStatus,
        connectionDuration: connectionDuration,
        serviceInfo: serviceInfo,
        simulateVehicleData: simulateVehicleData,
        isSearchingForHardware: _isSearchingForHardware,
        getSearchTime: () => _getSearchTime(),
        onActivateMockData: _activateMockData,
      ),
    );
  }
}

class OBDHome extends StatelessWidget {
  final VehicleData data;
  final DateTime? lastUpdate;
  final String connectionStatus;
  final Duration connectionDuration;
  final Map<String, dynamic>? serviceInfo;
  final Function simulateVehicleData;
  final bool isSearchingForHardware;
  final double Function() getSearchTime;
  final VoidCallback? onActivateMockData = null;
  final int currentGear = 0;

  const OBDHome({
    super.key,
    required this.data,
    this.lastUpdate,
    this.connectionStatus = 'Disconnected',
    this.connectionDuration = Duration.zero,
    this.serviceInfo,
    required this.simulateVehicleData,
    this.isSearchingForHardware = false,
    required this.getSearchTime,
    onActivateMockData,
  });

  String _format(double? value, String unit) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '--';
    final now = DateTime.now(),
        diff = now.millisecondsSinceEpoch - t.millisecondsSinceEpoch;
    if (diff < 1000) return 'Just now';
    if (diff < 60000) return '${(diff ~/ 1000).toString()}s ago';
    if (diff < 3600000) return '${(diff ~/ 60000).toString()}m ago';
    return t.toString().substring(11, 16);
  }

  @override
  Widget build(BuildContext context) {
    // Debug info panel for Windows PCAN/Kvaser detection
    final isMockMode =
        connectionStatus.contains('Mock') || !ServiceRouter.useRealHardware;

    // Check if using Bluetooth Serial mode (Windows)
    final isBluetoothSerialMode = connectionStatus.contains('Bluetooth');
    final usesRealHardware = ServiceRouter.useRealHardware && !isMockMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OBDII Monitor'),
        backgroundColor: Colors.teal[900],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[900]!, Colors.teal[800]!],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMockMode
                      ? [
                          const Color(0xFFFF9800),
                          const Color(0xFFFF7F50)
                        ] // Orange for mock
                      : connectionStatus.contains('Bluetooth')
                          ? [
                              Colors.blue[900]!,
                              Colors.blue[800]!
                            ] // Blue for Bluetooth
                          : [
                              Colors.teal[900]!,
                              Colors.teal[800]!
                            ], // Teal for real hardware
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(
                    isMockMode
                        ? Icons.rocket_launch_rounded // Mock data icon
                        : connectionStatus.contains('Bluetooth')
                            ? Icons.bluetooth // Bluetooth icon
                            : Icons.wifi, // WiFi icon for real hardware
                    color: isMockMode
                        ? Colors.orange
                        : connectionStatus.contains('Bluetooth')
                            ? Colors.lightBlue
                            : Colors.lightGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMockMode ? '📜 Mock Data Mode' : connectionStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ]),
            ),

            // Bluetooth/Serial Info (Windows OBD dongle mode)
            if (isBluetoothSerialMode) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[950]!,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(children: [
                  Icon(Icons.bluetooth,
                      size: 20, color: Colors.lightBlueAccent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📶 Bluetooth Serial Port OBD Mode\nThis app uses Windows Bluetooth Serial Port API to connect to classic Bluetooth OBD dongles like:\n• Vgate v3.0/VLink MKII\n• ODBLINK Pro\n• ELM327 Bluetooth adapters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ]),
              ),
            ],

            // Service Info Panel (debug mode or real hardware/Bluetooth)
            if (serviceInfo != null && usesRealHardware ||
                isBluetoothSerialMode) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📡 Service Information',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            isBluetoothSerialMode
                                ? '📶 Bluetooth Serial Port'
                                : ((serviceInfo?['serviceType'] ?? 'Unknown')
                                    as String),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: isBluetoothSerialMode
                              ? Colors.blue[900]!
                              : ((serviceInfo?['useRealHardware'] ?? false)
                                      as bool)
                                  ? Colors.green[900]!
                                  : Colors.grey[800]!,
                          padding: EdgeInsets.zero,
                        ),
                        Chip(
                          label: Text(
                            ((serviceInfo?['isWindows'] ?? false) as bool)
                                ? '🪟 Windows'
                                : '📱 Mobile',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[900]!,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tesla-Style Dashboard with RPM + Speed gauges (Layout Option 3)
            TeslaStyleDashboard(
              rpm: data.rpm ?? 0,
              speed: data.speed ?? 0,
              coolantTemp: data.coolantTemp ?? 0,
              intakeTemp: data.intakeTemp ?? 0,
              batteryVoltage: data.batteryVoltage ?? 0,
              gear: currentGear, // Track gear separately
              fuelLevel: (data.fuelLevel),
              throttlePosition: data.throttlePosition ?? 0,
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]!,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.battery_std,
                            color: (data.batteryVoltage ?? 0) > 12
                                ? Colors.green
                                : Colors.orange),
                        const SizedBox(height: 4),
                        Text(_format(data.batteryVoltage, 'V'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]!,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_fix_high, color: Colors.orange),
                        const SizedBox(height: 4),
                        Text(_format(data.throttlePosition, '%'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (data.dtcs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[900]!,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text('DTC Detected: ${data.dtcs}',
                            style: const TextStyle(color: Colors.white))),
                  ],
                ), // Close Row and Container.child
              ), // Close Container and separate from next widget in if block list

              // Update timestamp
              Row(children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(_formatTime(lastUpdate),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ]),

              const SizedBox(height: 32),

              // Raw Data Info Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[900]!.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.getStatusSummary(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: connectionStatus.contains('Bluetooth')
                      ? Colors.green[50]!
                      : Colors.orange[100]!,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          connectionStatus.contains('Bluetooth')
                              ? Icons.bluetooth
                              : Icons.info_outline,
                          color: connectionStatus.contains('Bluetooth')
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            connectionStatus.contains('Bluetooth')
                                ? '📶 Bluetooth Serial Port Mode'
                                : '💡 No Physical CAN Adapter Detected',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!connectionStatus.contains('Bluetooth'))
                      const SizedBox(height: 8),
                    if (!connectionStatus.contains('Bluetooth')) ...[
                      const Text(
                        'To use real ODBII data, please:',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1. Connect PCAN-USB adapter',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                  '   - Install drivers from https://pcan.com/'),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '2. Connect Kvaser adapter',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('   - Drivers auto-detect on Windows'),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Note: Tesla-style dashboard now uses digital-analog hybrid gauges:
// - RPM Gauge (left) with gear indicator and redline zone
// - Speedometer Gauge (right) with trip computer support
