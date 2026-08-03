# Dashboard Gauge Widgets

Modern car-inspired dashboard gauges for OBD app.

## Design Philosophy

- **Digital-Analog Hybrid**: Combines physical needle feel with digital clarity
- **Tesla-style Layout**: Clean, minimal, information-dense
- **Gear-Centric**: Gear indicator at top (like modern automatic cars)
- **Color-Coded RPM**: Blue → Cyan → Red as you approach redline

## Available Widgets

### `RpmGaugeWidget`

Modern digital-analog RPM gauge with:
- ✅ Top gear indicator (P/R/N/D with icons)
- ✅ Analog arc with needle shadow
- ✅ Digital fill bar underneath
- ✅ Large "8.450" RPM display in center
- ✅ Min/Max RPM range at bottom
- ✅ Redline zone highlighting

**Usage:**
```dart
RpmGaugeWidget(
  rpm: 3250.5,        // Current RPM (0-9000)
  gear: 3,            // Gear: -1=N, 0=D, 1-7=numeric gears
  onRpmChange: (rpm) {}, // Optional callback
)
```

## Color Scheme

| Component | Normal | Redline Zone | Warning (>8500) |
|-----------|--------|--------------|-----------------|
| RPM Display | White `#FFFFFF` | White | **Red** `#FF0000` |
| Fill Bar | Blue `#1E90FF` | Cyan → Red gradient | Red `#E94560` |
| Background | Dark Navy `#1A1A2E` | Carbon Fiber pattern | - |

## Tick Marks

- Every 500 RPM: Small tick (white)
- Every 1000 RPM: Numbered tick (white, bold)
- Redline zone (7000-9000): Red background gradient

## Gear Indicators

| Gear | Icon | Color |
|------|------|-------|
| P (Park) | ⚙️ | Yellow `#FFC107` |
| R (Reverse) | ↔️ | Yellow `#FFC107` |
| N (Neutral) | ⚙️ | Orange `#E67E22` |
| D (Drive) | → | White `#FFFFFF` |
| 1-7 (Manual) | ⚙️ | White `#FFFFFF` |

---

## Usage Example

```dart
Column(
  children: [
    RpmGaugeWidget(
      rpm: currentRpm,
      gear: currentGear,
      onRpmChange: (rpm) {
        print('New RPM: $rpm');
      },
    ),
  ],
)
```

---

## Next Steps

1. Speedometer Gauge (with gear indicator and trip computer)
2. Temperature Cluster (coolant + intake temps)
3. Fuel & Battery Widget (combined)
4. Warning Indicators Panel (LED-style warnings)
