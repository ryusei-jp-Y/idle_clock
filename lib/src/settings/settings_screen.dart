import 'package:flutter/material.dart';

import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _changeSettings(AppSettings settings) {
    setState(() {
      _settings = settings;
    });
    widget.onSettingsChanged(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          SwitchListTile(
            key: const ValueKey('settings-use-24-hour'),
            title: const Text('24時間表記'),
            subtitle: const Text('オフにするとAM/PM付きの12時間表記にします'),
            value: _settings.use24Hour,
            onChanged: (value) {
              _changeSettings(_settings.copyWith(use24Hour: value));
            },
          ),
          SwitchListTile(
            key: const ValueKey('settings-show-seconds'),
            title: const Text('秒を表示'),
            subtitle: const Text('時計に秒を含めます'),
            value: _settings.showSeconds,
            onChanged: (value) {
              _changeSettings(_settings.copyWith(showSeconds: value));
            },
          ),
          ListTile(
            title: const Text('表示モード'),
            subtitle: const Text('端末設定に合わせるか、ライト / ダークを固定します'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            trailing: SegmentedButton<AppThemePreference>(
              key: const ValueKey('settings-theme-preference'),
              segments: const [
                ButtonSegment(
                  value: AppThemePreference.system,
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: AppThemePreference.light,
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: AppThemePreference.dark,
                  label: Text('Dark'),
                ),
              ],
              selected: {_settings.themePreference},
              onSelectionChanged: (selection) {
                _changeSettings(
                  _settings.copyWith(themePreference: selection.first),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('移動オブジェクト数'),
            subtitle: Text('${_settings.objectCount}個'),
            trailing: SizedBox(
              width: 168,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    key: const ValueKey('settings-decrease-objects'),
                    tooltip: '減らす',
                    onPressed:
                        _settings.objectCount > AppSettings.minimumObjectCount
                        ? () {
                            _changeSettings(
                              _settings.copyWith(
                                objectCount: _settings.objectCount - 1,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '${_settings.objectCount}',
                    key: const ValueKey('settings-object-count'),
                  ),
                  IconButton(
                    key: const ValueKey('settings-increase-objects'),
                    tooltip: '増やす',
                    onPressed:
                        _settings.objectCount < AppSettings.maximumObjectCount
                        ? () {
                            _changeSettings(
                              _settings.copyWith(
                                objectCount: _settings.objectCount + 1,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
