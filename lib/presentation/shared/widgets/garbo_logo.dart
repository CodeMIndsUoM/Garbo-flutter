import 'package:flutter/material.dart';

/// Official Garbo brand logo (truck + wordmark), transparent background.
/// Outer white stroke is baked into [assetPath]; letter counters and the cab
/// window stay transparent so the hero image shows through.
class GarboLogo extends StatelessWidget {
  const GarboLogo({
    super.key,
    this.height = 120,
    this.width,
  });

  final double height;
  final double? width;

  static const assetPath = 'assets/images/garbo-logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}
