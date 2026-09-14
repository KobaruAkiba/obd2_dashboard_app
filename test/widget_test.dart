import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/app.dart';

void main() {
  testWidgets('OBD app boots into live cockpit shell', (tester) async {
    await tester.pumpWidget(const ObdApp());
    await tester.pump(); // first frame
    expect(find.text('OBD Monitor'), findsOneWidget);
    expect(find.text('Live'), findsWidgets);
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);

    // Mock switch lives on the Connection tab (debug builds).
    await tester.tap(find.text('Connection'));
    await tester.pumpAndSettle();
    expect(find.text('Mock data'), findsOneWidget);

    // Back to Live — gauges after stub connect delay (800ms).
    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('ENGINE'), findsOneWidget);
    expect(find.textContaining('SPEED'), findsOneWidget);
    expect(find.textContaining('COOLANT'), findsOneWidget);

    // Dispose services so periodic mock timers are cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
