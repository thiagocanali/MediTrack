/// A recorded medication dose. Does not imply that a reminder fired.
enum DoseStatus { taken }

class DoseRecord {
  const DoseRecord({
    required this.scheduledFor,
    required this.recordedAt,
    required this.status,
  });

  final DateTime scheduledFor;
  final DateTime recordedAt;
  final DoseStatus status;

  /// Only the explicitly supported status is accepted. This is intentionally
  /// strict so unsupported records are not silently shown as confirmed.
  factory DoseRecord.fromMap(Map<String, dynamic> data) {
    final scheduled = data['scheduledFor'];
    final recorded = data['recordedAt'];
    if (scheduled is! DateTime || recorded is! DateTime) {
      throw const FormatException('Datas do registro inválidas.');
    }
    if (data['status'] != 'taken') {
      throw const FormatException('Status de dose não reconhecido.');
    }
    if (scheduled.isAfter(recorded)) {
      throw const FormatException('Confirmação anterior ao horário da dose.');
    }
    return DoseRecord(
      scheduledFor: scheduled,
      recordedAt: recorded,
      status: DoseStatus.taken,
    );
  }
}
