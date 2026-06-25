class TableThread {
  final String threadId;
  final String createdByUserId;
  final String title;
  final bool? userContributed;
  final bool hasUnread;
  final bool assessmentMarked;
  final DateTime? lastActivityAt;

  const TableThread({
    required this.threadId,
    this.createdByUserId = '',
    required this.title,
    this.userContributed,
    this.hasUnread = false,
    this.assessmentMarked = false,
    this.lastActivityAt,
  });

  factory TableThread.fromJson(Map<String, dynamic> json) {
    return TableThread(
      threadId: (json['threadId'] ?? json['_id'] ?? '').toString(),
      createdByUserId: (json['createdByUserId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      userContributed: json['userContributed'] is bool
          ? json['userContributed'] as bool
          : null,
      hasUnread: json['hasUnread'] == true,
      assessmentMarked: json['assessmentMarked'] == true,
      lastActivityAt: DateTime.tryParse('${json['lastActivityAt'] ?? ''}'),
    );
  }

  TableThread copyWith({
    String? threadId,
    String? createdByUserId,
    String? title,
    bool? userContributed,
    bool? hasUnread,
    bool? assessmentMarked,
    DateTime? lastActivityAt,
  }) {
    return TableThread(
      threadId: threadId ?? this.threadId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      title: title ?? this.title,
      userContributed: userContributed ?? this.userContributed,
      hasUnread: hasUnread ?? this.hasUnread,
      assessmentMarked: assessmentMarked ?? this.assessmentMarked,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}
