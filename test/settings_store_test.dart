import 'package:flutter_test/flutter_test.dart';
import 'package:idle_clock/src/settings/app_settings.dart';
import 'package:idle_clock/src/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsStore', () {
    test('loads defaults when no values are saved', () async {
      SharedPreferences.setMockInitialValues({});

      final settings = await SettingsStore().load();

      expect(settings.use24Hour, isTrue);
      expect(settings.showSeconds, isTrue);
      expect(settings.objectCount, 1);
    });

    test('loads saved values', () async {
      SharedPreferences.setMockInitialValues({
        'settings.use24Hour': false,
        'settings.showSeconds': false,
        'settings.objectCount': 3,
        'settings.themePreference': 'light',
      });

      final settings = await SettingsStore().load();

      expect(settings.use24Hour, isFalse);
      expect(settings.showSeconds, isFalse);
      expect(settings.objectCount, 3);
      expect(settings.themePreference, AppThemePreference.light);
    });

    test('saves values', () async {
      SharedPreferences.setMockInitialValues({});

      await SettingsStore().save(
        const AppSettings(
          use24Hour: false,
          showSeconds: false,
          themePreference: AppThemePreference.dark,
        ),
      );
      final preferences = await SharedPreferences.getInstance();

      expect(preferences.getBool('settings.use24Hour'), isFalse);
      expect(preferences.getBool('settings.showSeconds'), isFalse);
      expect(preferences.getInt('settings.objectCount'), 1);
      expect(preferences.getString('settings.themePreference'), 'dark');
    });

    test('clamps saved object count', () async {
      SharedPreferences.setMockInitialValues({'settings.objectCount': 20});

      final settings = await SettingsStore().load();

      expect(settings.objectCount, 4);
    });
  });
}
