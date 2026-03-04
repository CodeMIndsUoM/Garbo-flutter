import 'package:flutter/material.dart';

/// Central color palette for the app.
abstract final class AppColors {
  // Primary greens
  static const Color green700 = Color(0xFF03824B);
  static const Color green800 = Color(0xFF026639);

  // Emerald palette
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emeraldLight = Color(0xFFDCFCE7);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);

  // Teal
  static const Color teal50 = Color(0xFFF0FDFA);

  // Blues
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBEDBFF);
  static const Color blue500 = Color(0xFF2B7FFF);
  static const Color blue600 = Color(0xFF155DFC);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color indigo50 = Color(0xFFEEF2FF);

  // Reds / alerts
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFFC9C9);
  static const Color red500 = Color(0xFFFB2C36);

  // Oranges
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange500 = Color(0xFFF54900);
  static const Color orange600 = Color(0xFFFF6900);

  // Purples
  static const Color purple50 = Color(0xFFF3E8FF);
  static const Color purple100 = Color(0xFFE9D5FF);
  static const Color purple200 = Color(0xFFD8B4FE);
  static const Color purple600 = Color(0xFF9810FA);

  // Yellows / Amber
  static const Color yellow = Color(0xFFFEF9C2);
  static const Color yellowOrange = Color(0xFFFFEDD4);
  static const Color amber600 = Color(0xFFD97706);

  // Neutrals
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DC);
  static const Color grey500 = Color(0xFF6A7282);
  static const Color grey600 = Color(0xFF4A5565);
  static const Color grey700 = Color(0xFF364153);
  static const Color grey900 = Color(0xFF101828);

  // Citizen palette neutrals
  static const Color citizenGrey500 = Color(0xFF6B7280);
  static const Color citizenGrey600 = Color(0xFF4B5563);
  static const Color citizenGrey900 = Color(0xFF111827);

  // Whites with opacity (ARGB)
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
}

typedef DesignTokens = AppColors;
