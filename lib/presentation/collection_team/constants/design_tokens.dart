import 'package:flutter/material.dart';

/// Shared design tokens for the Collection Team module.
/// Single source of truth for colors used across all widgets.
abstract final class DesignTokens {
  // ── Primary ─────────────────────────────────────────────────
  static const Color green700 = Color(0xFF03824B);

  // ── Reds / Alerts ───────────────────────────────────────────
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFFC9C9);
  static const Color red500 = Color(0xFFFB2C36);

  // ── Oranges ─────────────────────────────────────────────────
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange600 = Color(0xFFFF6900);

  // ── Blues ────────────────────────────────────────────────────
  static const Color blue500 = Color(0xFF155DFC);

  // ── Neutrals ────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DC);
  static const Color grey500 = Color(0xFF6A7282);
  static const Color grey600 = Color(0xFF4A5565);
  static const Color grey700 = Color(0xFF364153);
  static const Color grey900 = Color(0xFF101828);
}
