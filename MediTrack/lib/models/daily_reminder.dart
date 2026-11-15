/// A local wall-clock reminder time. This model does not schedule notifications
/// or persist medication data.
class DailyReminder {
  const DailyReminder({required this.hour, required this.minute})
      : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59);

  final int hour;
  final int minute;

  /// Returns the next occurrence strictly after [now], using the device's
  /// local time zone when [now] is local.
  ///
  /// On DST transitions, DateTime may normalize nonexistent local times.
  /// Notification scheduling must independently handle timezone changes.
  DateTime nextAfter(DateTime now) {
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return next;
  }

  Map<String, int> toMap() => {'hour': hour, 'minute': minute};

  static DailyReminder fromMap(Map<String, dynamic> map) {
    final hour = map['hour'];
    final minute = map['minute'];
    if (hour is! int || minute is! int ||
        hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const FormatException('Horário de lembrete inválido.');
    }
    return DailyReminder(hour: hour, minute: minute);
  }
}
