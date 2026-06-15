import 'package:flutter/material.dart';

/// Full-bleed auth hero with community illustration on brand-green background.
class AuthHeroBackground extends StatelessWidget {
  const AuthHeroBackground({
    super.key,
    this.imageOpacity = 1,
    this.imageScale = 1,
    this.imageAlignment = Alignment.bottomCenter,
    this.imageFit = BoxFit.contain,
  });

  static const assetPath = 'assets/images/login-hero-community.png';

  /// Dark brand green behind the cutout hero illustration.
  static const backgroundColor = Color(0xFF0F3D22);

  final double imageOpacity;
  final double imageScale;
  final Alignment imageAlignment;
  final BoxFit imageFit;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: imageOpacity,
            child: Transform.scale(
              scale: imageScale,
              child: Image.asset(
                assetPath,
                fit: imageFit,
                alignment: imageAlignment,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.12),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
