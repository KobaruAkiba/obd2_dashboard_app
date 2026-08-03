# OBD App - Dashboard Widget Usage Examples

## Quick Start: Both RPM and Speed Gauges Together

### Complete Tesla-Style Layout (Layout Option 3)

```dart
import 'package:flutter/material.dart';
import 'dashboard_layouts/tresla_style_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TeslaStyleDashboard(
          // RPM (main gauge - left side)
          rpm: 3250.5,
          gear: 3,  // Current gear (-1=N, 0=D, 1-7=manual)
          
          // Speed (right panel)
          speed: 85.3,
          
          // Temperature cluster
          coolantTemp: 92.0,
          intakeTemp: 45.0,
          
          // Other metrics
          batteryVoltage: 12.8,
          fuelLevel: 68.5,
          throttlePosition: 25.0,
        ),
      ),
    );
  }
}
```

---

## Standalone Gauge Examples

### RPM Gauge Only

```dart
import 'package:flutter/material.dart';
import 'gauge_widgets/widgets_export.dart';

class RpmOnlyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Main RPM gauge with gear indicator
            RpmGaugeWidget(
              rpm: 4500.0,
              gear: 4,
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Current Gear: D',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Speedometer Gauge Only

```dart
import 'package:flutter/material.dart';
import 'gauge_widgets/widgets_export.dart';

class SpeedOnlyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Speedometer with trip computer
            SpeedometerGaugeWidget(
              speed: 120.0,
              gear: 5,
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Speed: 120 km/h',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Integration with Your OBD Data

### From VehicleData Model

If you're using the existing `VehicleData` model, update your main.dart:

```dart
// In your state or data class
class DashboardState {
  double? rpm;
  int gear = 0;  // Track gear separately from RPM data
  double? speed;
  double? coolantTemp;
  double? intakeTemp;
  double? batteryVoltage;
  double? fuelLevel;
  double? throttlePosition;
}

// Usage in your screen:
class OBDDashboardScreen extends StatelessWidget {
  final DashboardState state;

  const OBDDashboardScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return TeslaStyleDashboard(
      rpm: state.rpm ?? 0,
      gear: state.gear,
      speed: state.speed ?? 0,
      coolantTemp: state.coolantTemp ?? 0,
      intakeTemp: state.intakeTemp ?? 0,
      batteryVoltage: state.batteryVoltage ?? 0,
      fuelLevel: state.fuelLevel ?? 0,
      throttlePosition: state.throttlePosition ?? 0,
    );
  }
}
```

### Gear Tracking

The gear indicator requires separate tracking since OBD-II PID doesn't include gear position:

```dart
// Option 1: Simple integer field
int currentGear = 0; // Default to Drive

// Option 2: Enum for clarity
enum Gear { park, reverse, neutral, drive, manual1, manual2, manual3, manual4, manual5, manual6, manual7 }

class VehicleData {
  int getGear() => gear;  // Add this field
}

// Option 3: Sync with RPM logic (heuristic)
int getCurrentGearFromRPM(double rpm) {
  if (rpm < 1000) return 0; // Park
  if (rpm > 7500 && rpm < 8500) return -1; // Near redline in drive
  
  // Default implementation
  return 0;
}
```

---

## Color-Coded Warning System

### Temperature Warnings (Automatic)

```dart
Text(
  '${coolantTemp.toStringAsFixed(0)}°C',
  style: TextStyle(
    color: coolantTemp < 95 
        ? Colors.green    // Safe zone
        : coolantTemp < 105 
            ? Colors.yellow  // Warning
            : Colors.red,   // Danger
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
)
```

### Battery Voltage Warnings

```dart
Icon(
  Icons.battery_std_rounded,
  color: batteryVoltage > 12.5 
      ? Colors.green       // Good
      : batteryVoltage > 12.0 
          ? Colors.orange   // Low - warn
          : Colors.red,     // Critical
),
```

---

## Performance Tips

### For Smooth Gauges

1. Use `SingleTickerState` for smooth animation if adding animations
2. Enable hardware acceleration in pubspec.yaml:
   ```yaml
   flutter:
     uses-material-design: true
     shaders:
       - your-shader.glsl
   ```
3. Consider using `AnimatedBuilder` for real-time updates

### For Production

1. Optimize CustomPainter repaints:
   ```dart
   @override
   bool shouldRepaint(CustomPainter oldDelegate) {
     return value > oldDelegate.value; // Only repaint when needed
   }
   ```

---

## Troubleshooting

### Issue: Gauge doesn't update in real-time

**Solution:** Check if `shouldRepaint` is working correctly. Add a debug print:
```dart
@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
  print('Repainting... value: $value');
  return true;
}
```

### Issue: Gear indicator shows wrong gear

**Solution:** Ensure you're passing the correct gear state:
```dart
// ✅ Correct
RpmGaugeWidget(rpm: rpm, gear: currentGear)

// ❌ Incorrect - don't calculate from RPM alone
RpmGaugeWidget(rpm: rpm, gear: getCurrentGearFromRPM(rpm))
```

### Issue: Text too small on small screens

**Solution:** Use responsive sizing:
```dart
Text(
  '8.5K',
  style: TextStyle(
    fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
  ),
)
```

---

## Next Steps

1. ✅ Add gauges to pubspec.yaml and run `flutter pub get`
2. ⬜ Test in main.dart with current VehicleData
3. ⬜ Add gear tracking logic to your service layer
4. ⬜ Integrate warning indicators (check engine, oil pressure)
5. ⬜ Consider adding trip computer A/B functionality

---

## File Locations

```
lib/widgets/
├── gauge_widgets/
│   ├── rpm_gauge_widget.dart          ← RPM implementation
│   ├── speedometer_gauge_widget.dart  ← Speedometer implementation
│   └── widgets_export.dart            ← Export all gauges
├── dashboard_components.dart           ← Gauge wrapper components
├── dashboard_layouts/
│   └── tresla_style_dashboard.dart    ← Full dashboard (Layout Option 3)
└── USAGE_EXAMPLES.md                   ← This file
```
