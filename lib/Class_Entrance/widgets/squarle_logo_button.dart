import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SquarleLogoButton extends StatelessWidget {
  final bool enabled;
  final bool dimmed;
  final bool isLoading;
  final double px;
  final VoidCallback? onTap;

  const SquarleLogoButton({
    super.key,
    required this.enabled,
    required this.dimmed,
    required this.isLoading,
    required this.px,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final asset = dimmed
        ? 'assets/logoButton/dim_squarle_logo.svg'
        : 'assets/logoButton/deep_squarle_logo.svg';

    return GestureDetector(
      onTap: enabled && !isLoading ? onTap : null,
      child: SizedBox(
        width: 102 * px,
        height: 102 * px,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Color(0xFF2B88CF))
              : SvgPicture.asset(
                  asset,
                  width: 102 * px,
                  height: 102 * px,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
