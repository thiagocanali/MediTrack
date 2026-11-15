import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/models/dose_record.dart';

void main() {
  final scheduled = DateTime.utc(2026, 11, 15, 8);
  final recorded = scheduled.add(const Duration(minutes: 2));

  test('parses an explicitly confirmed dose', () {
    final record = DoseRecord.fromMap({
      'scheduledFor': scheduled,
      'recordedAt': recorded,
      'status': 'taken',
    });
    expect(record.status, DoseStatus.taken);
    expect(record.scheduledFor, scheduled);
  });

  test('rejects unknown status', () {
    expect(() => DoseRecord.fromMap({
      'scheduledFor': scheduled,
      'recordedAt': recorded,
      'status': 'missed',
    }), throwsFormatException);
  });

  test('rejects confirmation before schedule', () {
    expect(() => DoseRecord.fromMap({
      'scheduledFor': recorded,
      'recordedAt': scheduled,
      'status': 'taken',
    }), throwsFormatException);
  });

  test('rejects missing timestamps', () {
    expect(() => DoseRecord.fromMap({'status': 'taken'}),
        throwsFormatException);
  });
}
