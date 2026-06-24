import '../../Squarle_Entrance/models/squarle_table.dart';

class SquarleJoinResult {
  final String? sessionId;
  final int? tableNumber;
  final int? view;
  final bool inQueue;
  final String message;
  final List<SquarleTable> visibleTables;

  const SquarleJoinResult({
    this.sessionId,
    this.tableNumber,
    this.view,
    this.inQueue = false,
    required this.message,
    this.visibleTables = const [],
  });

  factory SquarleJoinResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return SquarleJoinResult(
      sessionId: dataJson['sessionId']?.toString(),
      tableNumber: dataJson['tableNumber'] is int
          ? dataJson['tableNumber'] as int
          : int.tryParse('${dataJson['tableNumber']}'),
      view: dataJson['view'] is int
          ? dataJson['view'] as int
          : int.tryParse('${dataJson['view']}'),
      inQueue: dataJson['inQueue'] == true,
      message: json['message'] as String? ?? 'Joined squarle.',
      visibleTables: _parseVisibleTables(dataJson['visibleTables']),
    );
  }

  static List<SquarleTable> _parseVisibleTables(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map<String, dynamic>>()
        .map(SquarleTable.fromJson)
        .where((table) => table.tableNumber > 0)
        .toList();
  }
}
