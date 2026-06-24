class SquarleTable {
  final String id;
  final int tableNumber;
  final int occupancy;
  final String? status;

  const SquarleTable({
    required this.id,
    required this.tableNumber,
    required this.occupancy,
    this.status,
  });

  factory SquarleTable.fromJson(Map<String, dynamic> json) {
    final seats = json['seats'];

    return SquarleTable(
      id: (json['tableId'] ?? json['_id'] ?? '').toString(),
      tableNumber: json['tableNumber'] is int
          ? json['tableNumber'] as int
          : int.tryParse('${json['tableNumber']}') ?? 0,
      occupancy: json['occupancy'] is int
          ? json['occupancy'] as int
          : json['currentOccupancy'] is int
              ? json['currentOccupancy'] as int
              : seats is List
                  ? seats.length
                  : 0,
      status: json['status'] as String?,
    );
  }
}
