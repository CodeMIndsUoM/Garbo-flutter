import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';

/// Consistent card surface used across citizen tabs.
class CitizenSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const CitizenSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: AppDecorations.card(),
      child: child,
    );
  }
}
