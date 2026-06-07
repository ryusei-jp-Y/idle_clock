import 'package:flutter_test/flutter_test.dart';
import 'package:idle_clock/src/clock/clock_formatter.dart';

void main() {
  group('formatClockTime', () {
    test('formats a 24-hour time with seconds', () {
      final time = DateTime(2026, 6, 7, 0, 5, 9);

      expect(formatClockTime(time), '00:05:09');
    });

    test('formats midnight and afternoon in 12-hour time', () {
      final midnight = DateTime(2026, 6, 7, 0, 5, 9);
      final afternoon = DateTime(2026, 6, 7, 13, 45, 20);

      expect(formatClockTime(midnight, use24Hour: false), '12:05:09 AM');
      expect(formatClockTime(afternoon, use24Hour: false), '01:45:20 PM');
    });

    test('can hide seconds', () {
      final time = DateTime(2026, 6, 7, 23, 8, 42);

      expect(formatClockTime(time, showSeconds: false), '23:08');
    });
  });
}
