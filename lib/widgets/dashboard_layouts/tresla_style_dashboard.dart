import 'package:flutter/material.dart';
import '../gauge_widgets/widgets_export.dart';

/// Tesla-style Dashboard Layout (Layout Option 3)
/// Left: RPM gauge | Right: Speedometer + Info cards | Top: Gear indicator
class TeslaStyleDashboard extends StatelessWidget {
  final double rpm;
  // gear is provided via constructor
  final int gear;
  final double speed;
  final double coolantTemp;
  final double intakeTemp;
  final double batteryVoltage;
  final double fuelLevel;
  final double throttlePosition;

  const TeslaStyleDashboard({
    super.key,
    required this.rpm,
    required this.gear,
    required this.speed,
    required this.coolantTemp,
    required this.intakeTemp,
    required this.batteryVoltage,
    required this.fuelLevel,
    required this.throttlePosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Gear Indicator (top center)
          _buildGearIndicator(gear),

          const SizedBox(height: 12),

          // Main gauges side by side
          Row(
            children: [
              Expanded(child: RpmGaugeWidget(rpm, gear)),
              const SizedBox(width: 8),
              Expanded(child: SpeedometerGaugeWidget(speed, gear)),
            ],
          ),

          const SizedBox(height: 12),

          // Info cards grid
          _buildInfoCards(coolantTemp, intakeTemp, fuelLevel, batteryVoltage,
              throttlePosition),

          const SizedBox(height: 8),

          // Trip computer counters
          _buildTripComputer(),
        ],
      ),
    );
  }

  Widget _buildGearIndicator(int gear) {
    IconData icon;
    Color color;

    switch (gear) {
      case -1:
        icon = Icons.arrow_downward;
        color = Colors.orange;
        break; // N
      case 0:
        icon = Icons.arrow_forward;
        color = Colors.yellow;
        break; // D
      case 1:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 1
      case 2:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 2
      case 3:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 3
      case 4:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 4
      case 5:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 5
      case 6:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 6
      case 7:
        icon = Icons.arrow_right_alt;
        color = Colors.white;
        break; // Gear 7
      default:
        icon = Icons.arrow_downward;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            gear == -1 ? 'N' : gear.abs().toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(
    double coolantTemp,
    double intakeTemp,
    double fuelLevel,
    double batteryVoltage,
    double throttlePosition,
  ) {
    return SizedBox(
      height: 100,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          // Coolant & Intake Temp Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE94560).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFE94560).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text('Coolant',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${coolantTemp.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Divider(height: 8),
                const Text('Intake',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${intakeTemp.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Fuel & Battery Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3A7BD5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF3A7BD5).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text('Fuel',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${fuelLevel.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Divider(height: 8),
                const Text('Battery',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${batteryVoltage.toStringAsFixed(1)}V',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Throttle Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE94560).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFE94560).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text('Throttle',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${throttlePosition.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripComputer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ODO', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Text('-', style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('TRIP A',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Text('-', style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('TRIP B',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Text('-', style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
