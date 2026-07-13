import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idle_clock/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('resets cleanly after app lifecycle changes', (tester) async {
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump(const Duration(milliseconds: 500));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('bouncing-visual')), findsOneWidget);
  });

  testWidgets('opens settings and saves clock display changes', (tester) async {
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('settings-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings-show-seconds')));
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getBool('settings.showSeconds'), isFalse);
  });

  testWidgets('changes the moving object count from settings', (tester) async {
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('settings-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings-increase-objects')));
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();

    expect(find.text('2'), findsOneWidget);
    expect(preferences.getInt('settings.objectCount'), 2);
  });

  testWidgets('changes the theme preference from settings', (tester) async {
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('settings-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getString('settings.themePreference'), 'light');
  });

  testWidgets('caps the moving object count at the maximum', (tester) async {
    await tester.pumpWidget(const IdleClockApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('settings-button')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i += 1) {
      await tester.tap(find.byKey(const ValueKey('settings-increase-objects')));
      await tester.pumpAndSettle();
    }
    final preferences = await SharedPreferences.getInstance();
    final countText = tester.widget<Text>(
      find.byKey(const ValueKey('settings-object-count')),
    );

    expect(countText.data, '4');
    expect(preferences.getInt('settings.objectCount'), 4);
  });
}
