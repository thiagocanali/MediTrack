import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/models/dose_occurrence.dart';

void main() {
  test('same instant yields same occurrence ID across offsets', () {
    final utc = DateTime.utc(2026, 11, 15, 11);
    final local = utc.toLocal();
    expect(DoseOccurrence(scheduledFor: utc).id,
        DoseOccurrence(scheduledFor: local).id);
  });

  test('different scheduled instants have different IDs', () {
    final first = DateTime.utc(2026, 11, 15, 11);
    final second = first.add(const Duration(minutes: 1));
    expect(DoseOccurrence(scheduledFor: first).id,
        isNot(DoseOccurrence(scheduledFor: second).id));
  });

  test('round trips occurrence ID in UTC', () {
    final date = DateTime.utc(2026, 11, 15, 11, 30);
    final id = DoseOccurrence(scheduledFor: date).id;
    expect(DoseOccurrence.parseId(id), date);
  });

  test('rejects subsecond scheduled times', () {
    final date = DateTime.utc(2026, 11, 15, 11, 30, 0, 1);
    expect(() => DoseOccurrence(scheduledFor: date).id,
        throwsFormatException);
  });

  test('rejects invalid IDs', () {
    expect(() => DoseOccurrence.parseId('invalid'), throwsFormatException);
    expect(() => DoseOccurrence.parseId('-1'), throwsFormatException);
  });
}
