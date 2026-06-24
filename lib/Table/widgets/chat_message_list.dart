import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? starterMessage;
  final double px;
  final double py;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.px,
    required this.py,
    this.starterMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2A9DF4)),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 38 * px),
          child: Text(
            starterMessage?.trim().isNotEmpty == true
                ? starterMessage!.trim()
                : 'No messages yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13 * px,
              height: 1.45,
              color: const Color(0xFF9B9B9B),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20 * px, 18 * py, 22 * px, 18 * py),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return ChatMessageBubble(
          message: messages[index],
          px: px,
          py: py,
        );
      },
    );
  }
}
