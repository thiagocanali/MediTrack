import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/models/daily_reminder.dart';

void main() {
  group('DailyReminder', () {
    test('next occurrence is today if time is in the future', () {
      const reminder = DailyReminder(hour: 14, minute: 30);
      expect(reminder.nextAfter(DateTime(2026, 11, 15, 14, 0)),
          DateTime(2026, 11, 15, 14, 30));
    });

    test('next occurrence is tomorrow if time has passed', () {
      const reminder = DailyReminder(hour: 8, minute: 15);
      expect(reminder.nextAfter(DateTime(2026, 11, 15, 8, 16)),
          DateTime(2026, 11, 16, 8, 15));
    });

    test('exact reminder time rolls to next day', () {
      const reminder = DailyReminder(hour: 8, minute: 15);
      expect(reminder.nextAfter(DateTime(2026, 11, 15, 8, 15)),
          DateTime(2026, 11, 16, 8, 15));
    });

    test('handles month boundary', () {
      const reminder = DailyReminder(hour: 0, minute: 0);
      expect(reminder.nextAfter(DateTime(2026, 11, 30, 23, 59)),
          DateTime(2026, 12, 1, 0, 0));
    });

    test('serializes valid wall-clock time', () {
      const reminder = DailyReminder(hour: 9, minute: 5);
      expect(DailyReminder.fromMap(reminder.toMap()).hour, 9);
      expect(DailyReminder.fromMap(reminder.toMap()).minute, 5);
    });

    test('rejects malformed times', () {
      expect(() => DailyReminder.fromMap({'hour': 24, 'minute': 0}),
          throwsFormatException);
      expect(() => DailyReminder.fromMap({'hour': 12, 'minute': -1}),
          throwsFormatException);
      expect(() => DailyReminder.fromMap({'hour': '9', 'minute': 0}),
          throwsFormatException);
    });
  });
}
