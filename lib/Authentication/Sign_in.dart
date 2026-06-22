import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma canvas: 393 × 852 px
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    // Proportional helpers
    final double px = w / 393;
    final double py = h / 852;

    // Content frame: Left=27, Top=308, Width=340, Gap=40
    final double frameLeft   = 27  * px;
    final double frameTop    = 308 * py;
    final double frameWidth  = 340 * px;
    final double gap         = 40  * py;

    // Button dimensions  (width = frameWidth, height ≈ 56px from design)
    final double btnHeight   = 56  * py;
    final double btnRadius   = 50.0; // pill shape

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [

          // ── Corner decoration – top right ──────────────────────
          // Use padding.top to clear the status bar
          Positioned(
            top:   MediaQuery.of(context).padding.top + 12 * py,
            right: 16 * px,
            child: Image.asset(
              'assets/images/corner.png',
              width:  22 * px,
              height: 22 * px,
              fit: BoxFit.contain,
            ),
          ),

          // ── Corner decoration – bottom left ────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 28 * py,
            left:   16 * px,
            child: Image.asset(
              'assets/images/corner.png',
              width:  20 * px,
              height: 20 * px,
              fit: BoxFit.contain,
            ),
          ),

          // ── Main content frame ─────────────────────────────────
          Positioned(
            top:  frameTop,
            left: frameLeft,
            width: frameWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── Title ─────────────────────────────────────────
                SizedBox(
                  width: frameWidth,
                  child: Text(
                    'Welcome to Squarle',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize:      24 * px,
                      fontWeight:    FontWeight.w600,   // SemiBold
                      color:         const Color(0xFF2B88CF),
                      height:        1.0,               // 100% line height
                      letterSpacing: 0,
                    ),
                  ),
                ),

                SizedBox(height: 8 * py),

                // ── Subtitle ──────────────────────────────────────
                SizedBox(
                  width: frameWidth,
                  child: Text(
                    'Log in with your school email',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize:      14 * px,
                      fontWeight:    FontWeight.w400,
                      color:         const Color(0xFF9E9E9E),
                      height:        1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),

                SizedBox(height: gap),

                // ── Continue with Google button ────────────────────
                _SocialButton(
                  icon:  'assets/images/google.png',
                  label: 'Continue with Google',
                  width: frameWidth,
                  height: btnHeight,
                  radius: btnRadius,
                  iconSize: 20 * px,
                  px: px,
                ),

                SizedBox(height: 16 * py),

                // ── Continue with Microsoft button ─────────────────
                _SocialButton(
                  icon:  'assets/images/microsoft.png',
                  label: 'Continue with Microsoft',
                  width: frameWidth,
                  height: btnHeight,
                  radius: btnRadius,
                  iconSize: 20 * px,
                  px: px,
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ── Reusable Social Sign-in Button ────────────────────────────
class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final double width;
  final double height;
  final double radius;
  final double iconSize;
  final double px;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.width,
    required this.height,
    required this.radius,
    required this.iconSize,
    required this.px,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF82C8FF), // Lighter sky blue matching Figma
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 48 * px), // Fixed left padding to vertically align logos
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width:  20 * px,   // Proportional icon size
                height: 20 * px,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12 * px),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize:      16 * px,   // Proportional text size
                  fontWeight:    FontWeight.w400,
                  color:         const Color(0xFF000000),
                  height:        1.2,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
