import 'package:flutter/material.dart';

/// Dark automotive cockpit palette for an OBD / telemetry monitor.
///
/// High-contrast, glanceable values. Prefer these pairings:
/// - [onSurface] / [onSurfaceBright] on [background] or [surface]
/// - [onSurfaceMuted] on [background]/[surface] (labels, units)
/// - [onPrimary] on [accent]; [onDanger] on [danger]; [onWarning] on [warning]
/// - Do not put [muted] on [surfaceHigh] for body text — use [onSurfaceMuted]
class AppColors {
  // --- Surfaces (cool graphite, not purple) ---
  static const background = Color(0xFF070A0D);
  static const surface = Color(0xFF10161D);
  static const surfaceHigh = Color(0xFF182129);
  static const surfaceHighest = Color(0xFF1F2A35);
  static const border = Color(0xFF2E3A48);
  static const borderBright = Color(0xFF3D4A5C);
  static const gaugeTrack = Color(0xFF243040);

  // --- Text / on-surface ---
  /// Primary readout / body text (legacy alias: [speed]).
  static const onSurface = Color(0xFFF2F5F8);
  static const onSurfaceBright = Color(0xFFFFFFFF);
  /// Labels & units — ≥4.5:1 on [background]/[surface].
  static const onSurfaceMuted = Color(0xFFA8B3C2);
  /// Disabled / tertiary chrome only.
  static const muted = Color(0xFF7A8698);

  /// Legacy name used across gauges for primary readout color.
  static const speed = onSurface;

  // --- Brand / telemetry accents ---
  /// Live / OK / CAN — telematics green.
  static const accent = Color(0xFF2EE59D);
  /// RPM / instrument blue.
  static const rpm = Color(0xFF4EA2FF);
  /// BLE / wireless cyan.
  static const ble = Color(0xFF00C2FF);
  /// Classic BT / secondary link.
  static const bluetooth = Color(0xFF5B8CFF);

  // --- Semantic ---
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF3B3B);
  static const success = accent;
  static const info = ble;

  // --- On-semantic (text/icons on filled fills) ---
  static const onPrimary = Color(0xFF04100A);
  static const onDanger = Color(0xFFFFFFFF);
  static const onWarning = Color(0xFF1A1200);
  static const onBle = Color(0xFF001018);

  // --- Status LED fills (soft) ---
  static Color ledFill(Color c) => c.withValues(alpha: 0.18);
  static Color ledRing(Color c) => c.withValues(alpha: 0.55);
}
