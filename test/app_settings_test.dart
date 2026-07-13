import 'package:flutter_test/flutter_test.dart';
import 'package:idle_clock/src/settings/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('uses clock-friendly defaults', () {
      const settings = AppSettings();

      expect(settings.use24Hour, isTrue);
      expect(settings.showSeconds, isTrue);
      expect(settings.objectCount, 1);
      expect(settings.themePreference, AppThemePreference.system);
      expect(AppSettings.maximumObjectCount, 4);
    });

    test('copies selected fields', () {
      const settings = AppSettings();

      final updated = settings.copyWith(showSeconds: false);

      expect(updated.use24Hour, isTrue);
      expect(updated.showSeconds, isFalse);
      expect(updated.objectCount, 1);
      expect(updated.themePreference, AppThemePreference.system);
    });

    test('parses theme preference from storage values', () {
      expect(
        AppThemePreference.fromStorageValue('light'),
        AppThemePreference.light,
      );
      expect(
        AppThemePreference.fromStorageValue('dark'),
        AppThemePreference.dark,
      );
      expect(
        AppThemePreference.fromStorageValue('unknown'),
        AppThemePreference.system,
      );
    });
  });
}
