import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class SettingsStore {
  SettingsStore({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  static const _use24HourKey = 'settings.use24Hour';
  static const _showSecondsKey = 'settings.showSeconds';
  static const _objectCountKey = 'settings.objectCount';
  static const _themePreferenceKey = 'settings.themePreference';

  final Future<SharedPreferences> _preferences;

  Future<AppSettings> load() async {
    final preferences = await _preferences;

    return AppSettings(
      use24Hour: preferences.getBool(_use24HourKey) ?? true,
      showSeconds: preferences.getBool(_showSecondsKey) ?? true,
      objectCount: _readObjectCount(preferences),
      themePreference: AppThemePreference.fromStorageValue(
        preferences.getString(_themePreferenceKey),
      ),
    );
  }

  Future<void> save(AppSettings settings) async {
    final preferences = await _preferences;

    await preferences.setBool(_use24HourKey, settings.use24Hour);
    await preferences.setBool(_showSecondsKey, settings.showSeconds);
    await preferences.setInt(_objectCountKey, settings.objectCount);
    await preferences.setString(
      _themePreferenceKey,
      settings.themePreference.storageValue,
    );
  }

  int _readObjectCount(SharedPreferences preferences) {
    final storedValue = preferences.getInt(_objectCountKey);
    if (storedValue == null) {
      return AppSettings.minimumObjectCount;
    }

    return storedValue.clamp(
      AppSettings.minimumObjectCount,
      AppSettings.maximumObjectCount,
    );
  }
}
