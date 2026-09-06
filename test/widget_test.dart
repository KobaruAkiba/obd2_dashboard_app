import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obd_car_monitor/app.dart';

void main() {
  testWidgets('OBD app boots into dashboard', (tester) async {
    await tester.pumpWidget(const ObdApp());
    await tester.pump(); // first frame
    expect(find.text('OBD Monitor'), findsOneWidget);
    expect(find.text('Mock data'), findsOneWidget); // debug-only switch

    // Hardware stub connect delay is 800ms.
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('ENGINE'), findsOneWidget);
    expect(find.textContaining('SPEED'), findsOneWidget);

    // Dispose services so periodic mock timers are cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
