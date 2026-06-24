import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewThreadButton extends StatelessWidget {
  final double px;
  final double py;
  final VoidCallback? onPressed;

  const NewThreadButton({
    super.key,
    required this.px,
    required this.py,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x663498DB),
        fixedSize: Size(130 * px, 50 * py),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24 * px),
        ),
      ),
      child: Text(
        'New Thread',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15 * px,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
