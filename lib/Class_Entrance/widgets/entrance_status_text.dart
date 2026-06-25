import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EntranceStatusText extends StatelessWidget {
  final String message;
  final double px;

  const EntranceStatusText({
    super.key,
    required this.message,
    required this.px,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12 * px,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFFF5A00),
        height: 1.25,
      ),
    );
  }
}
