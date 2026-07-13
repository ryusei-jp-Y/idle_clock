import 'package:flutter/material.dart';

import '../bounce/bouncing_visual.dart';
import '../clock/clock_view.dart';
import '../settings/app_settings.dart';
import '../settings/settings_screen.dart';
import '../theme/app_theme.dart';

class IdleClockScreen extends StatelessWidget {
  const IdleClockScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    final visualTheme = clockVisualThemeOf(context);

    return Scaffold(
      backgroundColor: visualTheme.backgroundColor,
      body: SafeArea(
        child: _LandscapeViewport(
          child: Stack(
            fit: StackFit.expand,
            children: [
              BouncingVisual(objectCount: settings.objectCount),
              IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ClockView(
                        use24Hour: settings.use24Hour,
                        showSeconds: settings.showSeconds,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 18,
                child: _SubtleSettingsButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) {
                          return SettingsScreen(
                            settings: settings,
                            onSettingsChanged: onSettingsChanged,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubtleSettingsButton extends StatelessWidget {
  const _SubtleSettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('settings-button'),
      tooltip: '設定',
      iconSize: 18,
      color: clockVisualThemeOf(context).settingsIconColor,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(32),
        minimumSize: const Size.square(32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: Colors.transparent,
        hoverColor: const Color(0x1FF4F2FF),
        focusColor: const Color(0x1FF4F2FF),
        highlightColor: const Color(0x24F4F2FF),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.settings_outlined),
    );
  }
}

class _LandscapeViewport extends StatelessWidget {
  const _LandscapeViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size.width >= size.height) {
          return child;
        }

        final landscapeHeight = size.width * 9 / 16;
        return Center(
          child: SizedBox(
            width: size.width,
            height: landscapeHeight.clamp(0.0, size.height),
            child: child,
          ),
        );
      },
    );
  }
}
