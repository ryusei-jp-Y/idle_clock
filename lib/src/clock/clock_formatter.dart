String formatClockTime(
  DateTime time, {
  bool use24Hour = true,
  bool showSeconds = true,
}) {
  final hour = use24Hour ? time.hour : _twelveHour(time.hour);
  final parts = <String>[
    _twoDigits(hour),
    _twoDigits(time.minute),
    if (showSeconds) _twoDigits(time.second),
  ];
  final suffix = use24Hour
      ? ''
      : time.hour < 12
      ? ' AM'
      : ' PM';

  return '${parts.join(':')}$suffix';
}

int _twelveHour(int hour) {
  final converted = hour % 12;
  return converted == 0 ? 12 : converted;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
