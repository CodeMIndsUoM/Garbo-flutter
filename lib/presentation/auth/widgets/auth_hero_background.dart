import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

/// Full-bleed auth hero photo with brand overlay — matches web dashboard login.
class AuthHeroBackground extends StatelessWidget {
  const AuthHeroBackground({
    super.key,
    this.imageOpacity = 1,
    this.imageScale = 1,
    this.imageAlignment = Alignment.center,
  });

  static const assetPath = 'assets/images/login-hero.jpg';

  final double imageOpacity;
  final double imageScale;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.emerald900,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: imageOpacity,
            child: Transform.scale(
              scale: imageScale,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                alignment: imageAlignment,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0x4716A34A),
                  Color(0x6B0F172A),
                  Color(0x940F172A),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
