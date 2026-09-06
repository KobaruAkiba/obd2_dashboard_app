import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/connection_status.dart';
import '../models/vehicle_data.dart';
import '../services/obd_service.dart';
import '../services/service_router.dart';
import '../theme/app_theme.dart';
import '../widgets/cockpit_dashboard.dart';
import '../widgets/connection_banner.dart';
import '../widgets/dtc_alert_banner.dart';

/// Owns connection lifecycle and feeds the cockpit UI.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ObdService? _service;
  StreamSubscription<VehicleData>? _dataSub;
  StreamSubscription<ObdConnectionState>? _stateSub;

  VehicleData _data = const VehicleData();
  DateTime? _lastUpdate;
  ConnectionMode _mode = ConnectionMode.connecting;
  String _detail = 'Starting OBD service…';
  Map<String, dynamic> _serviceInfo = const {};

  /// Debug-only: when true, use [MockObdService] instead of hardware stubs.
  bool _useMock = false;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    // Mock is opt-in via the debug switch (or explicit OBD_SERVICE_TYPE=mock).
    _useMock = kDebugMode && ServiceRouter.preferMock;
    _bootstrap();
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    _stateSub?.cancel();
    _service?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _serviceInfo = ServiceRouter.getServiceStatus();
    setState(() {
      _mode = ConnectionMode.connecting;
      _detail = 'Selecting data source…';
    });

    try {
      final service = await ServiceRouter.createService(useMock: _useMock);
      await _attachService(service);
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) {
        setState(() {
          _mode = ConnectionMode.error;
          _detail = 'Could not start service. Enable mock to continue.';
        });
      } else {
        setState(() {
          _mode = ConnectionMode.error;
          _detail = 'Could not start OBD service.';
        });
      }
    }
  }

  Future<void> _attachService(ObdService service) async {
    await _dataSub?.cancel();
    await _stateSub?.cancel();
    _service?.dispose();

    _service = service;
    _stateSub = service.connectionState.listen(_onConnectionState);
    _dataSub = service.vehicleData.listen((data) {
      if (!mounted) return;
      setState(() {
        _data = data;
        _lastUpdate = DateTime.now();
      });
    });

    await service.connect();
    if (!mounted) return;

    setState(() {
      _mode = _modeFor(service);
      _detail = service.displayName;
      _serviceInfo = ServiceRouter.getServiceStatus();
    });
  }

  ConnectionMode _modeFor(ObdService service) {
    final name = service.displayName.toLowerCase();
    if (name.contains('mock')) return ConnectionMode.mock;
    if (name.contains('bluetooth') || name.contains('ble')) {
      return ConnectionMode.bluetooth;
    }
    if (name.contains('can')) return ConnectionMode.canBus;
    return ConnectionMode.disconnected;
  }

  void _onConnectionState(ObdConnectionState state) {
    if (!mounted) return;
    setState(() {
      switch (state) {
        case ObdConnectionState.connecting:
          _mode = ConnectionMode.connecting;
          _detail = 'Connecting to ${_service?.displayName ?? 'device'}…';
        case ObdConnectionState.connected:
          if (_service != null) {
            _mode = _modeFor(_service!);
            _detail = _service!.displayName;
          }
        case ObdConnectionState.error:
          _mode = ConnectionMode.error;
          _detail = 'Connection error';
        case ObdConnectionState.disconnected:
          _mode = ConnectionMode.disconnected;
          _detail = 'Disconnected';
      }
    });
  }

  Future<void> _onMockChanged(bool enabled) async {
    if (!kDebugMode || _switching) return;

    setState(() {
      _useMock = enabled;
      _switching = true;
      _mode = ConnectionMode.connecting;
      _detail = enabled ? 'Switching to mock…' : 'Switching to hardware stub…';
    });

    try {
      final service = await ServiceRouter.createService(useMock: enabled);
      await _attachService(service);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mode = ConnectionMode.error;
        _detail = 'Failed to switch data source';
      });
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  String _formatLastUpdate() {
    final t = _lastUpdate;
    if (t == null) return 'Waiting for data…';
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 2) return 'Live';
    if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
    return 'Updated ${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD Monitor'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(_mode.icon, size: 16, color: _mode.color),
              label: Text(_mode.label),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (kDebugMode) ...[
              _MockModeSwitch(
                value: _useMock,
                enabled: !_switching,
                onChanged: _onMockChanged,
              ),
              const SizedBox(height: 12),
            ],
            ConnectionBanner(
              mode: _mode,
              detail: _detail,
            ),
            const SizedBox(height: 20),
            CockpitDashboard(data: _data),
            const SizedBox(height: 16),
            DtcAlertBanner(codes: _data.dtcs),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(
                  _formatLastUpdate(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    _data.rpm != null ? _data.statusSummary : '',
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              _DebugPanel(
                info: _serviceInfo,
                mode: _mode,
                useMock: _useMock,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MockModeSwitch extends StatelessWidget {
  const _MockModeSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: const Text('Mock data'),
        subtitle: Text(
          value ? 'Simulated telemetry' : 'Hardware stub path',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        secondary: Icon(
          Icons.science_outlined,
          color: value ? AppColors.warning : AppColors.muted,
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({
    required this.info,
    required this.mode,
    required this.useMock,
  });

  final Map<String, dynamic> info;
  final ConnectionMode mode;
  final bool useMock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEBUG', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            'mode=$mode  useMock=$useMock  service=${info['serviceType']}  '
            'preferMock=${info['preferMock']}  windows=${info['isWindows']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
