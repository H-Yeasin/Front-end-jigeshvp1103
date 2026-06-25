import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════
// Settings Screen
// Figma: 3 states –
//   1. Filled  → "Jigesh Padel" in field, checkmark full opacity
//   2. Empty   → "Preferred Name" placeholder, checkmark 0.5 opacity
//   3. Editing → new text typed, checkmark full opacity
// ═══════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  final String initialKnownName;
  final String displayName;

  const SettingsScreen({
    super.key,
    required this.initialKnownName,
    required this.displayName,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late FocusNode _focusNode;

  late final AnimationController _entranceController;
  late final AnimationController _buttonPressController;
  late final Animation<double> _profileFade;
  late final Animation<double> _cardFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _profileSlide;
  late final Animation<Offset> _cardSlide;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonPressScale;

  // Live tracking of whether field has text
  bool _hasText = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialKnownName);
    _focusNode = FocusNode();
    _hasText = widget.initialKnownName.trim().isNotEmpty;

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _profileFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.58, curve: Curves.easeOut),
    );
    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.16, 0.78, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.32, 1, curve: Curves.easeOut),
    );
    _profileSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0, 0.66, curve: Curves.easeOutCubic),
          ),
        );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.16, 0.82, curve: Curves.easeOutCubic),
          ),
        );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.32, 1, curve: Curves.easeOutBack),
          ),
        );
    _buttonPressScale = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeOut),
    );

    // Listen to text changes for real-time UI updates
    _nameController.addListener(_onTextChanged);
    _entranceController.forward();
  }

  void _onTextChanged() {
    final bool nowHasText = _nameController.text.trim().isNotEmpty;
    if (nowHasText != _hasText) {
      setState(() => _hasText = nowHasText);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    _focusNode.dispose();
    _entranceController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  void _onSave() {
    final String text = _nameController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      Navigator.pop(context, text);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Responsive scaling – Figma canvas 393 × 852
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    final double safeTop = MediaQuery.of(context).padding.top;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset keeps the scaffold from auto-resizing;
      // we handle keyboard offset manually via Stack + Positioned.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────
          Positioned.fill(
            bottom: keyboardHeight, // push content up when keyboard shows
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Figma: content starts at Top 226px from screen top
                      SizedBox(height: (226 * py) - safeTop),

                      // ── Profile Section (156 × 144 Hug, Gap 16px) ─────
                      FadeTransition(
                        opacity: _profileFade,
                        child: SlideTransition(
                          position: _profileSlide,
                          child: _buildProfileSection(px, py),
                        ),
                      ),

                      // Figma: parent frame gap = 16px
                      SizedBox(height: 16 * py),

                      // ── Name Edit Card (361 × 128 Hug) ─────────────────
                      FadeTransition(
                        opacity: _cardFade,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: _buildNameEditCard(px, py),
                        ),
                      ),

                      // Figma: parent frame gap = 16px
                      SizedBox(height: 16 * py),

                      // ── Checkmark Save Button (64 × 64) ────────────────
                      FadeTransition(
                        opacity: _buttonFade,
                        child: SlideTransition(
                          position: _buttonSlide,
                          child: _buildCheckmarkButton(px, py),
                        ),
                      ),

                      // Bottom breathing room
                      SizedBox(height: 48 * py),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Profile Section – 156 × 144, centered, Gap 16px
  // ══════════════════════════════════════════════════════════════════
  Widget _buildProfileSection(double px, double py) {
    return SizedBox(
      width: 156 * px,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar Circle – 80×80, Radius 39px, Border 3px #2D2D2D ──
          Container(
            width: 80 * px,
            height: 80 * px,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(39 * px),
              border: Border.all(color: const Color(0xFF2D2D2D), width: 3 * px),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                _getInitials(widget.displayName),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28 * px,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),

          SizedBox(height: 16 * py), // Gap 16px within profile frame
          // ── Display Name + Verified badge ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.displayName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18 * px,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1C1E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4 * px),
              Icon(
                Icons.verified,
                color: const Color(0xFF8E8E93),
                size: 16 * px,
              ),
            ],
          ),

          SizedBox(height: 4 * py),

          // ── "Verified as ..." – 156 Fill × 15 Hug, #888888, 12px ───
          SizedBox(
            width: 156 * px,
            child: Text(
              'Verified as ${widget.initialKnownName}',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12 * px,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF888888),
                height: 1.0, // 100% line height
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Name Edit Card
  // Figma: 361 Fill × 128 Hug, bg #F6FBFF, border 1px #73C5FF,
  //        radius 16px, padding T16 R12 B16 L12, gap 32px
  // ══════════════════════════════════════════════════════════════════
  Widget _buildNameEditCard(double px, double py) {
    return Container(
      width: 361 * px,
      padding: EdgeInsets.only(
        top: 16 * py,
        bottom: 16 * py,
        left: 12 * px,
        right: 12 * px,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBFF),
        borderRadius: BorderRadius.circular(16 * px),
        border: Border.all(color: const Color(0xFF73C5FF), width: 1 * px),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction text
          Text(
            "Enter the name you\u2019re known by in class.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14 * px,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1C1E),
            ),
          ),

          SizedBox(height: 32 * py), // Figma gap: 32px
          // ── Input capsule ─────────────────────────────────────────
          Container(
            height: 48 * py,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24 * px),
              border: Border.all(color: const Color(0xFF73C5FF), width: 1 * px),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16 * px),
            child: Row(
              children: [
                // Text field
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14 * px,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1C1E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Preferred Name',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14 * px,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFBABABA),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Pencil/edit icon – always visible
                _PremiumTap(
                  haptic: true,
                  onTap: () => _focusNode.requestFocus(),
                  child: Icon(
                    Icons.edit_outlined,
                    color: const Color(0xFF1A1C1E),
                    size: 18 * px,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Checkmark Button
  // Figma: 64×64, radius 50px, gradient #58AAE3 → #1F7FC9
  //        Shadow: X0 Y2 Blur8 Spread0 #000000 25%
  // Logic:
  //   • Field has text  → opacity 1.0, tap saves & pops
  //   • Field is empty  → opacity 0.5, tap does nothing
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCheckmarkButton(double px, double py) {
    return GestureDetector(
      onTapDown: _hasText ? (_) => _buttonPressController.forward() : null,
      onTapUp: _hasText ? (_) => _buttonPressController.reverse() : null,
      onTapCancel: _hasText ? () => _buttonPressController.reverse() : null,
      onTap: _hasText ? _onSave : null,
      child: ScaleTransition(
        scale: _buttonPressScale,
        child: AnimatedOpacity(
          opacity: _hasText ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 64 * px,
            height: 64 * px,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF58AAE3), Color(0xFF1F7FC9)],
              ),
              borderRadius: BorderRadius.circular(50 * px),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000), // 25% black
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 28 * px,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Utility: extract initials from name
  // ══════════════════════════════════════════════════════════════════
  String _getInitials(String name) {
    if (name.isEmpty) return 'JP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

class _PremiumTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool haptic;

  const _PremiumTap({
    required this.child,
    required this.onTap,
    this.haptic = false,
  });

  @override
  State<_PremiumTap> createState() => _PremiumTapState();
}

class _PremiumTapState extends State<_PremiumTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
