import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'clock_formatter.dart';

typedef CurrentTime = DateTime Function();

class ClockView extends StatefulWidget {
  const ClockView({
    super.key,
    this.use24Hour = true,
    this.showSeconds = true,
    this.now = DateTime.now,
  });

  final bool use24Hour;
  final bool showSeconds;
  final CurrentTime now;

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  Timer? _timer;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = widget.now();
    _scheduleNextTick();
  }

  @override
  void didUpdateWidget(ClockView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.now != oldWidget.now) {
      _time = widget.now();
      _timer?.cancel();
      _scheduleNextTick();
    }
  }

  void _scheduleNextTick() {
    final now = widget.now();
    final untilNextSecond = Duration(milliseconds: 1000 - now.millisecond);
    _timer = Timer(untilNextSecond, _tick);
  }

  void _tick() {
    if (!mounted) {
      return;
    }

    setState(() {
      _time = widget.now();
    });
    _scheduleNextTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = formatClockTime(
      _time,
      use24Hour: widget.use24Hour,
      showSeconds: widget.showSeconds,
    );
    final viewportSize = MediaQuery.sizeOf(context);
    final fontSize = (viewportSize.shortestSide * 0.3).clamp(72.0, 148.0);
    final visualTheme = clockVisualThemeOf(context);

    return Semantics(
      label: '現在時刻',
      value: formattedTime,
      child: Row(
        key: const ValueKey('clock-time'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final character in formattedTime.split(''))
            Text(
              character,
              style: _clockTextStyle.copyWith(
                color: visualTheme.clockColor,
                fontSize: fontSize,
              ),
            ),
        ],
      ),
    );
  }
}

const _clockTextStyle = TextStyle(
  color: Color(0xFFF4F2FF),
  fontFamily: 'BitcountGridDouble',
  fontWeight: FontWeight.w400,
  letterSpacing: 2,
  fontFeatures: [FontFeature.tabularFigures()],
);
