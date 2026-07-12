import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SquarleNoticeTone { green, orange }

class SquarleNoticeDialog extends StatefulWidget {
  final String message;
  final SquarleNoticeTone tone;
  final double px;
  final double py;
  final VoidCallback? onDismiss;

  const SquarleNoticeDialog({
    super.key,
    required this.message,
    required this.tone,
    required this.px,
    required this.py,
    this.onDismiss,
  });

  @override
  State<SquarleNoticeDialog> createState() => _SquarleNoticeDialogState();
}

class _SquarleNoticeDialogState extends State<SquarleNoticeDialog> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss?.call();
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.tone == SquarleNoticeTone.green
        ? const Color(0xFF00C925)
        : const Color(0xFFFF6B00);
    final bg = widget.tone == SquarleNoticeTone.green
        ? const Color(0xFFE5FFE9)
        : const Color(0xFFFFEFE5);

    return GestureDetector(
      onTap: () {
        widget.onDismiss?.call();
        Navigator.of(context).maybePop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 246 * widget.px,
          height: 193 * widget.py,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * widget.px),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 31 * widget.px,
                height: 31 * widget.px,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 17 * widget.px,
                    height: 17 * widget.px,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.tone == SquarleNoticeTone.green
                          ? Icons.check_rounded
                          : Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 12 * widget.px,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16 * widget.py),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26 * widget.px),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13 * widget.px,
                    fontWeight: FontWeight.w400,
                    color: color,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
