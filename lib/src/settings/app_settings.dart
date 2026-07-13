enum AppThemePreference {
  system('auto'),
  light('light'),
  dark('dark');

  const AppThemePreference(this.storageValue);

  final String storageValue;

  static AppThemePreference fromStorageValue(String? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.storageValue == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class AppSettings {
  const AppSettings({
    this.use24Hour = true,
    this.showSeconds = true,
    this.objectCount = 1,
    this.themePreference = AppThemePreference.system,
  }) : assert(objectCount >= minimumObjectCount),
       assert(objectCount <= maximumObjectCount);

  static const minimumObjectCount = 1;
  static const maximumObjectCount = 4;

  final bool use24Hour;
  final bool showSeconds;
  final int objectCount;
  final AppThemePreference themePreference;

  AppSettings copyWith({
    bool? use24Hour,
    bool? showSeconds,
    int? objectCount,
    AppThemePreference? themePreference,
  }) {
    return AppSettings(
      use24Hour: use24Hour ?? this.use24Hour,
      showSeconds: showSeconds ?? this.showSeconds,
      objectCount: objectCount ?? this.objectCount,
      themePreference: themePreference ?? this.themePreference,
    );
  }
}
