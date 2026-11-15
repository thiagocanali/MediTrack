/// Stable local identity for a scheduled dose occurrence.
///
/// Uses UTC milliseconds to avoid collisions at daylight-saving transitions.
/// Include the medication document path when using this ID outside its
/// per-medication Firestore subcollection.
class DoseOccurrence {
  const DoseOccurrence({required this.scheduledFor});

  final DateTime scheduledFor;

  String get id {
    final utc = scheduledFor.toUtc();
    if (utc.microsecond != 0 || utc.millisecond != 0) {
      throw const FormatException('A ocorrência deve ter precisão de segundos.');
    }
    return utc.millisecondsSinceEpoch.toString();
  }

  static DateTime parseId(String id) {
    if (!RegExp(r'^[0-9]{13}$').hasMatch(id)) {
      throw const FormatException('Identificador de dose inválido.');
    }
    final milliseconds = int.parse(id);
    final parsed = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    );
    if (parsed.millisecondsSinceEpoch != milliseconds) {
      throw const FormatException('Identificador fora do intervalo.');
    }
    return parsed;
  }
}
