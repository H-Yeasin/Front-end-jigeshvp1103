import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SquarleNoticeTone { green, orange }

class SquarleNoticeDialog extends StatelessWidget {
  final String message;
  final SquarleNoticeTone tone;
  final double px;
  final double py;

  const SquarleNoticeDialog({
    super.key,
    required this.message,
    required this.tone,
    required this.px,
    required this.py,
  });

  @override
  Widget build(BuildContext context) {
    final color = tone == SquarleNoticeTone.green
        ? const Color(0xFF00C925)
        : const Color(0xFFFF6B00);
    final bg = tone == SquarleNoticeTone.green
        ? const Color(0xFFE5FFE9)
        : const Color(0xFFFFEFE5);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 246 * px,
        height: 193 * py,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * px),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 31 * px,
              height: 31 * px,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 17 * px,
                  height: 17 * px,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(
                    tone == SquarleNoticeTone.green
                        ? Icons.check_rounded
                        : Icons.check_rounded,
                    color: Colors.white,
                    size: 12 * px,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16 * py),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26 * px),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13 * px,
                  fontWeight: FontWeight.w400,
                  color: color,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
