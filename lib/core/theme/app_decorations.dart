import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Shared card and layout styles (field staff theme).
abstract final class AppDecorations {
  static const double pageHorizontalPadding = 24;
  static const double cardRadius = 16;

  static BorderRadius get cardBorderRadius =>
      BorderRadius.circular(cardRadius);

  /// Thin outline — avoids a heavy highlighted border on cards.
  static BoxBorder get cardBorder =>
      Border.all(color: AppColors.border, width: 1);

  /// Minimal elevation; the border carries most of the separation.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.shadowXs,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static BoxDecoration card({Color? color, BoxBorder? border}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: cardBorderRadius,
      border: border ?? cardBorder,
      boxShadow: cardShadow,
    );
  }

  /// Borderless input for search bars nested inside [card] containers.
  static InputDecoration searchInput({
    required String hintText,
    TextStyle? hintStyle,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    bool filled = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle ??
          AppTypography.bodyMd.copyWith(color: AppColors.grey500),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: filled,
      fillColor: filled ? AppColors.inputFill : null,
      isDense: true,
      contentPadding: contentPadding,
    );
  }

  /// Standard filled text field decoration for forms.
  static InputDecoration fieldInput({
    required String label,
    Widget? suffixIcon,
    String? hintText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    );

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey500),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputFill,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: AppColors.green700, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Legacy icon container — background removed; icons render as symbol only.
  static BoxDecoration metricIconBox({Color? background}) {
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }
}
