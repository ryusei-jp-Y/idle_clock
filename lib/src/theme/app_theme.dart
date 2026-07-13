import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

ThemeMode themeModeForPreference(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

class ClockVisualTheme extends ThemeExtension<ClockVisualTheme> {
  const ClockVisualTheme({
    required this.backgroundColor,
    required this.clockColor,
    required this.settingsIconColor,
    required this.rippleColor,
    required this.objectSaturation,
    required this.objectValue,
    required this.objectAlpha,
    required this.objectGlowAlpha,
    required this.objectOutlineAlpha,
  });

  final Color backgroundColor;
  final Color clockColor;
  final Color settingsIconColor;
  final Color rippleColor;
  final double objectSaturation;
  final double objectValue;
  final double objectAlpha;
  final double objectGlowAlpha;
  final double objectOutlineAlpha;

  static const dark = ClockVisualTheme(
    backgroundColor: Color(0xFF090A0F),
    clockColor: Color(0xFFF4F2FF),
    settingsIconColor: Color(0x73F4F2FF),
    rippleColor: Color(0xFFBFEFFF),
    objectSaturation: 0.55,
    objectValue: 1,
    objectAlpha: 0.94,
    objectGlowAlpha: 0.18,
    objectOutlineAlpha: 0.8,
  );

  static const light = ClockVisualTheme(
    backgroundColor: Color(0xFFF6F3EE),
    clockColor: Color(0xFF191922),
    settingsIconColor: Color(0x80191922),
    rippleColor: Color(0xFF4B8FD9),
    objectSaturation: 0.45,
    objectValue: 0.88,
    objectAlpha: 0.88,
    objectGlowAlpha: 0.10,
    objectOutlineAlpha: 0.72,
  );

  @override
  ThemeExtension<ClockVisualTheme> copyWith({
    Color? backgroundColor,
    Color? clockColor,
    Color? settingsIconColor,
    Color? rippleColor,
    double? objectSaturation,
    double? objectValue,
    double? objectAlpha,
    double? objectGlowAlpha,
    double? objectOutlineAlpha,
  }) {
    return ClockVisualTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      clockColor: clockColor ?? this.clockColor,
      settingsIconColor: settingsIconColor ?? this.settingsIconColor,
      rippleColor: rippleColor ?? this.rippleColor,
      objectSaturation: objectSaturation ?? this.objectSaturation,
      objectValue: objectValue ?? this.objectValue,
      objectAlpha: objectAlpha ?? this.objectAlpha,
      objectGlowAlpha: objectGlowAlpha ?? this.objectGlowAlpha,
      objectOutlineAlpha: objectOutlineAlpha ?? this.objectOutlineAlpha,
    );
  }

  @override
  ThemeExtension<ClockVisualTheme> lerp(
    covariant ThemeExtension<ClockVisualTheme>? other,
    double t,
  ) {
    if (other is! ClockVisualTheme) {
      return this;
    }

    return ClockVisualTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      clockColor: Color.lerp(clockColor, other.clockColor, t)!,
      settingsIconColor: Color.lerp(
        settingsIconColor,
        other.settingsIconColor,
        t,
      )!,
      rippleColor: Color.lerp(rippleColor, other.rippleColor, t)!,
      objectSaturation: _lerpDouble(
        objectSaturation,
        other.objectSaturation,
        t,
      ),
      objectValue: _lerpDouble(objectValue, other.objectValue, t),
      objectAlpha: _lerpDouble(objectAlpha, other.objectAlpha, t),
      objectGlowAlpha: _lerpDouble(objectGlowAlpha, other.objectGlowAlpha, t),
      objectOutlineAlpha: _lerpDouble(
        objectOutlineAlpha,
        other.objectOutlineAlpha,
        t,
      ),
    );
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final visualTheme = brightness == Brightness.dark
      ? ClockVisualTheme.dark
      : ClockVisualTheme.light;

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: visualTheme.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8C7BFF),
      brightness: brightness,
    ),
    extensions: [visualTheme],
  );
}

double _lerpDouble(double begin, double end, double t) {
  return begin + (end - begin) * t;
}

ClockVisualTheme clockVisualThemeOf(BuildContext context) {
  return Theme.of(context).extension<ClockVisualTheme>() ??
      ClockVisualTheme.dark;
}
