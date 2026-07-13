import 'dart:async';

import 'package:flutter/material.dart';

import 'home/idle_clock_screen.dart';
import 'settings/app_settings.dart';
import 'settings/settings_store.dart';
import 'theme/app_theme.dart';

class IdleClockApp extends StatefulWidget {
  const IdleClockApp({super.key, this.settingsStore});

  final SettingsStore? settingsStore;

  @override
  State<IdleClockApp> createState() => _IdleClockAppState();
}

class _IdleClockAppState extends State<IdleClockApp> {
  late final SettingsStore _settingsStore;
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    _settingsStore = widget.settingsStore ?? SettingsStore();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsStore.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _settings = settings;
    });
  }

  void _changeSettings(AppSettings settings) {
    setState(() {
      _settings = settings;
    });
    unawaited(_settingsStore.save(settings));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Clock',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeModeForPreference(_settings.themePreference),
      home: IdleClockScreen(
        settings: _settings,
        onSettingsChanged: _changeSettings,
      ),
    );
  }
}
