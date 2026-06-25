class SquarleStatus {
  final bool isOpen;
  final bool quietHours;
  final String? message;
  final DateTime? quietHoursStartsAt;
  final String? term;
  final int? year;

  const SquarleStatus({
    required this.isOpen,
    required this.quietHours,
    this.message,
    this.quietHoursStartsAt,
    this.term,
    this.year,
  });

  bool get isJoinable => isOpen && !quietHours;

  bool get isQuietWarning {
    final startsAt = quietHoursStartsAt;
    if (!quietHours && startsAt != null) {
      final secondsUntilStart = startsAt.difference(DateTime.now()).inSeconds;
      return secondsUntilStart > 0 && secondsUntilStart <= 15 * 60;
    }

    final text = message?.toLowerCase() ?? '';
    return text.startsWith('quiet hours will begin in');
  }

  String get displayMessage {
    if (quietHours) return 'Quiet hours are active.';
    if (isQuietWarning && message != null) return message!;
    if (isJoinable) return 'Tap to join';
    return 'The squarle opens when enough students add the class.';
  }

  int? get warningMinutes {
    final text = message;
    if (text == null) return null;
    final match = RegExp(r'in\s+(\d+)\s+minutes?').firstMatch(text);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  factory SquarleStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return SquarleStatus(
      isOpen: dataJson['isOpen'] == true,
      quietHours: dataJson['quietHours'] == true,
      message: dataJson['message'] as String?,
      quietHoursStartsAt: DateTime.tryParse(
        dataJson['quietHoursStartsAt'] as String? ?? '',
      ),
      term: dataJson['term'] as String?,
      year: dataJson['year'] is int
          ? dataJson['year'] as int
          : int.tryParse('${dataJson['year']}'),
    );
  }
}
