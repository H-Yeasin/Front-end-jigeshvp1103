class ChatMessage {
  final String id;
  final String threadId;
  final String userId;
  final String type;
  final String content;
  final String? userName;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.type,
    required this.content,
    this.userName,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['_id'] ?? json['messageId'] ?? '').toString(),
      threadId: (json['threadId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      content: (json['content'] ?? '').toString(),
      userName: (json['userName'] ?? json['authorName'] ?? json['name'])
          ?.toString(),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }
}
