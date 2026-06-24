import 'table_thread.dart';

class TableDetail {
  final int tableNumber;
  final bool isUserTable;
  final bool canParticipate;
  final bool quietHours;
  final List<TableThread> threads;

  const TableDetail({
    required this.tableNumber,
    required this.isUserTable,
    required this.canParticipate,
    required this.quietHours,
    required this.threads,
  });

  factory TableDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : json;
    final threads = dataJson['threads'];

    return TableDetail(
      tableNumber: dataJson['tableNumber'] is int
          ? dataJson['tableNumber'] as int
          : int.tryParse('${dataJson['tableNumber']}') ?? 0,
      isUserTable: dataJson['isUserTable'] == true,
      canParticipate: dataJson['canParticipate'] == true,
      quietHours: dataJson['quietHours'] == true,
      threads: threads is List
          ? threads
              .whereType<Map<String, dynamic>>()
              .map(TableThread.fromJson)
              .where((thread) => thread.threadId.isNotEmpty)
              .toList()
          : const [],
    );
  }

  TableDetail copyWith({
    int? tableNumber,
    bool? isUserTable,
    bool? canParticipate,
    bool? quietHours,
    List<TableThread>? threads,
  }) {
    return TableDetail(
      tableNumber: tableNumber ?? this.tableNumber,
      isUserTable: isUserTable ?? this.isUserTable,
      canParticipate: canParticipate ?? this.canParticipate,
      quietHours: quietHours ?? this.quietHours,
      threads: threads ?? this.threads,
    );
  }
}
