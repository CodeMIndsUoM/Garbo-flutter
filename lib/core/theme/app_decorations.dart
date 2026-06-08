import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

/// Shared card and layout styles (field staff theme).
abstract final class AppDecorations {
  static const double pageHorizontalPadding = 24;

  static BoxDecoration card({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grey200, width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color(0x05000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration metricIconBox({Color? background}) {
    return BoxDecoration(
      color: background ?? AppColors.greenSurface2,
      borderRadius: BorderRadius.circular(14),
    );
  }
}
