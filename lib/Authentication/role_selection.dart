import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'date_of_birth.dart';


class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String _selectedRole = 'Student';

  late AnimationController _avatarController;
  late Animation<double> _avatarFade;
  late Animation<double> _avatarScale;

  late AnimationController _avatarFloatController;
  late Animation<double> _avatarFloat;

  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late List<AnimationController> _optionControllers;
  late List<Animation<double>> _optionFades;
  late List<Animation<Offset>> _optionSlides;

  late AnimationController _buttonController;
  late Animation<double> _buttonFade;
  late Animation<double> _buttonScale;

  late AnimationController _cornerController;
  late Animation<double> _cornerFade;
  late Animation<double> _cornerScale;

  late AnimationController _rolePulseController;
  late Animation<double> _rolePulseScale;
  String _pulsedRole = '';

  final List<String> _roles = ['Student', 'Instructor', 'Other'];

  @override
  void initState() {
    super.initState();

    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOut),
    );
    _avatarScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOutBack),
    );

    _avatarFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _avatarFloat = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _avatarFloatController, curve: Curves.easeInOut),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    _optionControllers = List.generate(
      _roles.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _optionFades = _optionControllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      );
    }).toList();
    _optionSlides = _optionControllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(-0.15, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack));
    }).toList();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );

    _cornerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cornerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeOut),
    );
    _cornerScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeOutBack),
    );

    _rolePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _rolePulseScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _rolePulseController, curve: Curves.easeInOut),
    );

    _cornerController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _avatarController.forward().then((_) {
          _avatarFloatController.repeat(reverse: true);
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _titleController.forward();
    });
    for (int i = 0; i < _roles.length; i++) {
      Future.delayed(Duration(milliseconds: 380 + i * 100), () {
        if (mounted) _optionControllers[i].forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _avatarFloatController.dispose();
    _titleController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    _buttonController.dispose();
    _cornerController.dispose();
    _rolePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    final double px = w / 393;
    final double py = h / 852;

    final double frameLeft   = 27  * px;
    final double frameTop    = 204 * py;
    final double frameWidth  = 340 * px;
    final double frameHeight = 444 * py;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [

          Positioned(
            top:   MediaQuery.of(context).padding.top + 12 * py,
            right: 16 * px,
            child: FadeTransition(
              opacity: _cornerFade,
              child: ScaleTransition(
                scale: _cornerScale,
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/images/top_corner.png',
                  width:  22 * px,
                  height: 22 * px,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 28 * py,
            left:   16 * px,
            child: FadeTransition(
              opacity: _cornerFade,
              child: ScaleTransition(
                scale: _cornerScale,
                alignment: Alignment.bottomLeft,
                child: Image.asset(
                  'assets/images/bottom_corner.png',
                  width:  20 * px,
                  height: 20 * px,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Positioned(
            top:    frameTop,
            left:   frameLeft,
            width:  frameWidth,
            height: frameHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Column(
                  children: [
                    FadeTransition(
                      opacity: _avatarFade,
                      child: ScaleTransition(
                        scale: _avatarScale,
                        child: AnimatedBuilder(
                          animation: _avatarFloat,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _avatarFloat.value),
                              child: child,
                            );
                          },
                          child: Container(
                            width:  106 * px,
                            height: 106 * px,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF1FF).withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width:  86 * px,
                              height: 86 * px,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFF1FF).withOpacity(0.55),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                width:  65 * px,
                                height: 65 * px,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDFF1FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/person_icon.png',
                                    width:  17.5 * px,
                                    height: 19.5 * px,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24 * py),

                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: SizedBox(
                          width: frameWidth,
                          child: Text(
                            'What is your role at your school?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize:      16 * px,
                              fontWeight:    FontWeight.w400,
                              color:         const Color(0xFF2D2D2D),
                              height:        1.4,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10 * py),

                Column(
                  children: [
                    for (int i = 0; i < _roles.length; i++) ...[
                      FadeTransition(
                        opacity: _optionFades[i],
                        child: SlideTransition(
                          position: _optionSlides[i],
                          child: _buildRoleOption(_roles[i], px, py),
                        ),
                      ),
                      if (i < _roles.length - 1) SizedBox(height: 12 * px),
                    ],

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: _selectedRole != 'Student' ? 34 * py : 0,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: 16 * py),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: _selectedRole != 'Student' ? 1.0 : 0.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: const Color(0xFFFF6E00),
                                    size: 16 * px,
                                  ),
                                  SizedBox(width: 8 * px),
                                  Text(
                                    'Squarle is intended for student use only.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize:   14 * px,
                                      fontWeight: FontWeight.w400,
                                      color:      const Color(0xFFFF6E00),
                                      height:     1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(top: 26 * py),
                  child: FadeTransition(
                    opacity: _buttonFade,
                    child: ScaleTransition(
                      scale: _buttonScale,
                      child: _buildCheckButton(px, py),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String role, double px, double py) {
    final bool isSelected = _selectedRole == role;
    final bool isPulsed   = _pulsedRole == role;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pulsedRole = role);
        _rolePulseController.forward();
      },
      onTapUp: (_) {
        _rolePulseController.reverse().then((_) {
          if (mounted) setState(() => _pulsedRole = '');
        });
        setState(() => _selectedRole = role);
      },
      onTapCancel: () {
        _rolePulseController.reverse().then((_) {
          if (mounted) setState(() => _pulsedRole = '');
        });
      },
      child: AnimatedBuilder(
        animation: _rolePulseScale,
        builder: (context, child) {
          return Transform.scale(
            scale: isPulsed ? _rolePulseScale.value : 1.0,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  340 * px,
          height: 40 * px,
          padding: EdgeInsets.symmetric(horizontal: 16 * px),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF73C5FF),
              width: 0.5 * px,
            ),
            borderRadius: BorderRadius.circular(20 * px),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF73C5FF).withOpacity(0.15),
                      blurRadius: 8 * px,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width:  18 * px,
                height: 18 * px,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1F7FC9)
                        : const Color(0xFF73C5FF),
                    width: 1.5 * px,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:  isSelected ? 10 * px : 0,
                    height: isSelected ? 10 * px : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F7FC9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * px),
              Text(
                role,
                style: GoogleFonts.plusJakartaSans(
                  fontSize:   16 * px,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF1A1C1E)
                      : const Color(0xFF6A6A6A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckButton(double px, double py) {
    final bool isStudent = _selectedRole == 'Student';
    return _AnimatedCheckButton(
      onTap: isStudent
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DateOfBirthScreen(),
                ),
              );
            }
          : null,
      px: px,
    );
  }
}

// ── Animated Check Button ──────────────────────────────────────────
class _AnimatedCheckButton extends StatefulWidget {
  final VoidCallback? onTap;
  final double px;

  const _AnimatedCheckButton({required this.onTap, required this.px});

  @override
  State<_AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<_AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown:   isEnabled ? (_) => _pressController.forward() : null,
      onTapUp:     isEnabled ? (_) => _pressController.reverse() : null,
      onTapCancel: isEnabled ? ()  => _pressController.reverse() : null,
      onTap:       widget.onTap,
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  64 * widget.px,
          height: 64 * widget.px,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled ? null : const Color(0xFF9BCDF3),
            gradient: isEnabled
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF58AAE3),
                      Color(0xFF1F7FC9),
                    ],
                  )
                : null,
            boxShadow: isEnabled
                ? [
                    const BoxShadow(
                      color: Color(0x3D1F7FC9),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32 * widget.px,
            ),
          ),
        ),
      ),
    );
  }
}