import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquarleBottomControls extends StatefulWidget {
  final double px;
  final double py;
  final bool isLoading;
  final Future<void> Function() onSlideOut;

  const SquarleBottomControls({
    super.key,
    required this.px,
    required this.py,
    required this.onSlideOut,
    this.isLoading = false,
  });

  @override
  State<SquarleBottomControls> createState() => _SquarleBottomControlsState();
}

class _SquarleBottomControlsState extends State<SquarleBottomControls> {
  double _dragOffset = 0;

  double get _maxDrag => 188 * widget.px;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.isLoading) return;

    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(0, _maxDrag);
    });
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (widget.isLoading) return;

    if (_dragOffset >= _maxDrag * 0.65) {
      setState(() => _dragOffset = _maxDrag);
      await widget.onSlideOut();
      if (mounted) setState(() => _dragOffset = 0);
      return;
    }

    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final px = widget.px;
    final py = widget.py;

    return Container(
      width: 252 * px,
      height: 62 * py,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(34 * px),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedPositioned(
            duration: widget.isLoading
                ? Duration.zero
                : const Duration(milliseconds: 120),
            left: 1 * px + _dragOffset,
            child: GestureDetector(
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Container(
                width: 64 * px,
                height: 64 * px,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 18 * px,
                          height: 18 * px,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2B88CF),
                          ),
                        )
                      : Image.asset(
                          'assets/icons/slideout.png',
                          width: 24 * px,
                          height: 24 * px,
                        ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: 42 * px),
              child: Text(
                'Slide Out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16 * px,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E8E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
