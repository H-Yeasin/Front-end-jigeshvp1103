import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/class_item.dart';

class EntranceClassTile extends StatelessWidget {
  final ClassItem classItem;
  final double px;
  final double py;

  const EntranceClassTile({
    super.key,
    required this.classItem,
    required this.px,
    required this.py,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8 * px, 8 * py, 8 * px, 12 * py),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFE),
        borderRadius: BorderRadius.circular(8 * px),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  classItem.semesterLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22 * px,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1784E6),
                    height: 1.1,
                  ),
                ),
              ),
              Icon(
                Icons.copy_rounded,
                color: const Color(0xFF1784E6),
                size: 22 * px,
              ),
            ],
          ),
          SizedBox(height: 10 * py),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 8 * px,
              vertical: 12 * py,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6 * px),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classItem.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13 * px,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1C1E),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6 * py),
                Text(
                  classItem.teacher,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12 * px,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF888888),
                    height: 1.2,
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
