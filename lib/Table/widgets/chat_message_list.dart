import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatefulWidget {
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
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopBlur = false;
  bool _showBottomBlur = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateBlurIndicators);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateBlurIndicators(),
    );
  }

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length ||
        oldWidget.isLoading != widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateBlurIndicators(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateBlurIndicators)
      ..dispose();
    super.dispose();
  }

  void _updateBlurIndicators() {
    if (!mounted || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    final showTop = position.pixels > position.minScrollExtent + 1;
    final showBottom = position.pixels < position.maxScrollExtent - 1;

    if (showTop == _showTopBlur && showBottom == _showBottomBlur) return;

    setState(() {
      _showTopBlur = showTop;
      _showBottomBlur = showBottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2A9DF4)),
      );
    }

    if (widget.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 38 * widget.px),
          child: Text(
            widget.starterMessage?.trim().isNotEmpty == true
                ? widget.starterMessage!.trim()
                : 'No messages yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13 * widget.px,
              height: 1.45,
              color: const Color(0xFF9B9B9B),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _updateBlurIndicators(),
            );
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              20 * widget.px,
              18 * widget.py,
              22 * widget.px,
              18 * widget.py,
            ),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              return ChatMessageBubble(
                message: widget.messages[index],
                px: widget.px,
                py: widget.py,
              );
            },
          ),
        ),
        if (_showTopBlur)
          _ScrollBlurIndicator(
            alignment: Alignment.topCenter,
            height: 30 * widget.py,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        if (_showBottomBlur)
          _ScrollBlurIndicator(
            alignment: Alignment.bottomCenter,
            height: 34 * widget.py,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
      ],
    );
  }
}

class _ScrollBlurIndicator extends StatelessWidget {
  final Alignment alignment;
  final double height;
  final Alignment begin;
  final Alignment end;

  const _ScrollBlurIndicator({
    required this.alignment,
    required this.height,
    required this.begin,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: alignment,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 1.2),
              child: Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    stops: const [0, 0.58, 1],
                    colors: const [
                      Color(0xC9FFFFFF),
                      Color(0x66FFFFFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
