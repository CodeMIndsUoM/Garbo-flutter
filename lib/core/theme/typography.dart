import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

/// Central typography scale for the app.
///
/// All roles (citizen, collection_team, field_staff, third_party_collector)
/// should consume these styles instead of declaring inline TextStyle values.
///
/// Usage:
///   Text('Title', style: AppTypography.h3)
///   Text('On green', style: AppTypography.h1.copyWith(color: Colors.white))
///
/// To switch to a bundled font (e.g. Arimo), register the font in pubspec.yaml
/// and update [fontFamily] below — every style updates automatically.
abstract final class AppTypography {
  static const String? fontFamily = null;

  // ── Display / Hero numbers ────────────────────────────────────────────
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.grey900,
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.grey900,
  );
  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.grey900,
  );

  // ── Headings (page / section titles) ──────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.grey900,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.grey900,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.grey900,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.grey900,
  );

  // ── Titles (card header, list item) ───────────────────────────────────
  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.grey900,
  );
  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.grey900,
  );
  static const TextStyle titleSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.grey900,
  );

  // ── Body ──────────────────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.grey700,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.grey700,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.grey500,
  );

  // ── Labels & Captions ─────────────────────────────────────────────────
  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.grey600,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.grey600,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.grey500,
  );
  static const TextStyle captionSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.grey500,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.3,
    color: AppColors.grey500,
  );

  // ── Buttons ───────────────────────────────────────────────────────────
  static const TextStyle buttonLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle buttonMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ── Specialized ───────────────────────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: Colors.white,
  );
  static const TextStyle quote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontStyle: FontStyle.italic,
    color: AppColors.grey500,
  );
}
