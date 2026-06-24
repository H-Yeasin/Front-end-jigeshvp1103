import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final double px;
  final double py;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.px,
    required this.py,
  });

  String _timeLabel(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.toLocal().hour;
    final minute = dateTime.toLocal().minute.toString().padLeft(2, '0');
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final name = message.userName?.trim().isNotEmpty == true
        ? message.userName!.trim()
        : 'Member';

    return Padding(
      padding: EdgeInsets.only(bottom: 22 * py),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58 * px,
            child: Text(
              _timeLabel(message.createdAt),
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10 * px,
                color: const Color(0xFF969696),
              ),
            ),
          ),
          SizedBox(width: 14 * px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13 * px,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                        ),
                      ),
                    ),
                    SizedBox(width: 5 * px),
                    Icon(
                      Icons.check_circle,
                      size: 9 * px,
                      color: const Color(0xFF9A9A9A),
                    ),
                  ],
                ),
                SizedBox(height: 9 * py),
                Text(
                  message.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13 * px,
                    height: 1.35,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
