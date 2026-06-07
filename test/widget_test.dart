import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idle_clock/src/app.dart';

void main() {
  testWidgets('shows the clock and bouncing visual', (tester) async {
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump();

    expect(find.byKey(const ValueKey('clock-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('bouncing-visual')), findsOneWidget);
  });

  testWidgets('keeps rendering after the viewport changes size', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.binding.setSurfaceSize(const Size(844, 390));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('bouncing-visual')), findsOneWidget);
  });
}
