import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// Neutral tokens (greys, surfaces, shadows) and the semantic tokens
/// ([surface], [background], [textPrimary], etc.) resolve based on the active
/// [brightness], which is synced from the running [ThemeMode] in `App.build`.
///
/// Pastel / status-surface tokens also adapt in dark mode so fills and tags
/// stay readable on `#1a1a1a` backgrounds. Saturated brand accents (e.g.
/// [emerald600], [red500]) stay fixed across themes.
abstract final class AppColors {
  /// Active brightness driving the dynamic neutral/semantic tokens.
  /// Updated at the top of the widget tree on every rebuild.
  static Brightness brightness = Brightness.light;

  static bool get _dark => brightness == Brightness.dark;

  /// Primary dark-theme page background (#1a1a1a).
  static const Color darkBackground = Color(0xFF1A1A1A);

  // Primary greens (fixed accents)
  static const Color green700 = Color(0xFF17A34A);
  static const Color green800 = Color(0xFF17A34A);

  // Emerald palette — pastels are brightness-aware; accents stay fixed.
  static Color get emerald50 =>
      _dark ? const Color(0xFF0D2218) : const Color(0xFFECFDF5);
  static Color get emerald100 =>
      _dark ? const Color(0xFF143528) : const Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static Color get emeraldLight =>
      _dark ? const Color(0xFF1A3D2E) : const Color(0xFFDCFCE7);
  static const Color emerald500 = Color(0xFF17A34A);
  static const Color emerald600 = Color(0xFF17A34A);
  static const Color emerald700 = Color(0xFF17A34A);
  static const Color emerald800 = Color(0xFF17A34A);
  static const Color emerald900 = Color(0xFF17A34A);

  // Teal
  static Color get teal50 =>
      _dark ? const Color(0xFF0D2422) : const Color(0xFFF0FDFA);

  // Blues
  static Color get blue50 =>
      _dark ? const Color(0xFF142238) : const Color(0xFFEFF6FF);
  static Color get blue100 =>
      _dark ? const Color(0xFF1A3050) : const Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBEDBFF);
  static const Color blue500 = Color(0xFF2B7FFF);
  static const Color blue600 = Color(0xFF155DFC);
  static const Color blue700 = Color(0xFF1D4ED8);
  static Color get indigo50 =>
      _dark ? const Color(0xFF1A1F3D) : const Color(0xFFEEF2FF);

  // Reds / alerts
  static Color get red50 =>
      _dark ? const Color(0xFF2A1515) : const Color(0xFFFEF2F2);
  static Color get red100 =>
      _dark ? const Color(0xFF3D1A1A) : const Color(0xFFFFC9C9);
  static const Color red500 = Color(0xFFFB2C36);

  // Oranges
  static Color get orange50 =>
      _dark ? const Color(0xFF2A1A0D) : const Color(0xFFFFF7ED);
  static const Color orange200 = Color(0xFFFFAF76);
  static const Color orange500 = Color(0xFFF54900);
  static const Color orange600 = Color(0xFFFF6900);

  // Purples
  static Color get purple50 =>
      _dark ? const Color(0xFF251A33) : const Color(0xFFF3E8FF);
  static Color get purple100 =>
      _dark ? const Color(0xFF302040) : const Color(0xFFE9D5FF);
  static const Color purple200 = Color(0xFFD8B4FE);
  static const Color purple600 = Color(0xFF9810FA);

  // Yellows / Amber
  static Color get yellow =>
      _dark ? const Color(0xFF3D3510) : const Color(0xFFFEF9C2);
  static const Color yellow400 = Color(0xFFFACC15);
  static Color get yellowOrange =>
      _dark ? const Color(0xFF3D2A15) : const Color(0xFFFFEDD4);
  static const Color amber600 = Color(0xFFD97706);

  // Neutrals (brightness-aware)
  static Color get grey50 => _dark ? darkBackground : const Color(0xFFFFFFFF);
  static Color get grey100 => _dark ? const Color(0xFF262626) : const Color(0xFFF1F5F9);
  static Color get grey200 => _dark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
  static Color get grey300 => _dark ? const Color(0xFF404040) : const Color(0xFFCBD5E1);
  static Color get grey400 => _dark ? const Color(0xFF5A5A5A) : const Color(0xFF94A3B8);
  static Color get grey500 => _dark ? const Color(0xFF939393) : const Color(0xFF64748B);
  static Color get grey600 => _dark ? const Color(0xFFABABAB) : const Color(0xFF475569);
  static Color get grey700 => _dark ? const Color(0xFFC4C4C4) : const Color(0xFF334155);
  static Color get grey900 => _dark ? const Color(0xFFE6E6E6) : const Color(0xFF1E293B);

  // Citizen palette neutrals (brightness-aware)
  static Color get citizenGrey500 => _dark ? const Color(0xFF9AA6B2) : const Color(0xFF6B7280);
  static Color get citizenGrey600 => _dark ? const Color(0xFFB3BECA) : const Color(0xFF4B5563);
  static Color get citizenGrey900 => _dark ? const Color(0xFFE6EAEF) : const Color(0xFF111827);

  // ── Semantic surface / text tokens (brightness-aware) ────────────────────
  /// Default page / scaffold background.
  static Color get background => _dark ? darkBackground : const Color(0xFFFFFFFF);

  /// Card / sheet / app bar fill that sits above [background].
  static Color get surface => _dark ? const Color(0xFF242424) : const Color(0xFFFFFFFF);

  /// Slightly raised / alternate surface (subtle fills, chips).
  static Color get surfaceVariant => _dark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC);

  /// Primary text & high-emphasis icons.
  static Color get textPrimary => grey900;

  /// Secondary text & medium-emphasis icons.
  static Color get textSecondary => grey600;

  /// Card / input outlines.
  static Color get border => grey200;

  /// Text fields, dropdowns, and nested search bars.
  static Color get inputFill =>
      _dark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC);

  /// Default page / tab canvas — same as [background]; prefer [background] for scaffolds.
  static Color get canvas => background;

  /// Hairline dividers.
  static Color get divider => grey100;

  /// Neutral pill / chip fill (e.g. ID badges).
  static Color get chipFill => grey200;

  /// Text on neutral pills / chips.
  static Color get chipText => grey700;

  // Whites with opacity (ARGB) — used over brand-green surfaces, stay fixed.
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  // Shadows / scrims (brightness-aware — heavier in dark)
  static Color get shadowXs => _dark ? const Color(0x33000000) : const Color(0x0A000000);
  static Color get shadowSm => _dark ? const Color(0x40000000) : const Color(0x19000000);
  static Color get shadowMd => _dark ? const Color(0x4D000000) : const Color(0x1F000000);
  static Color get scrim => _dark ? const Color(0x99000000) : const Color(0x66000000);

  // Status surfaces — fill-level / report severity backgrounds & borders
  static Color get amberSurface =>
      _dark ? const Color(0xFF3D3010) : const Color(0xFFFFFBEB);
  static Color get amberSurface2 =>
      _dark ? const Color(0xFF3D3210) : const Color(0xFFFFF6D8);
  static Color get amberSurface3 =>
      _dark ? const Color(0xFF3D3410) : const Color(0xFFFFF8E1);
  static Color get amberBorder =>
      _dark ? const Color(0xFF5C4A20) : const Color(0xFFFDE68A);
  static Color get amberBorder2 =>
      _dark ? const Color(0xFF6B5525) : const Color(0xFFFFECAA);
  static Color get redBorder =>
      _dark ? const Color(0xFF5C3030) : const Color(0xFFFECACA);
  static Color get redSurface2 =>
      _dark ? const Color(0xFF3D1818) : const Color(0xFFFFE2E2);
  static Color get greenSurface2 =>
      _dark ? const Color(0xFF142A1C) : const Color(0xFFE2FBE9);
  static Color get greenSurface3 =>
      _dark ? const Color(0xFF1A3324) : const Color(0xFFE8FDF0);
  static Color get greenBorder2 =>
      _dark ? const Color(0xFF2A5C3A) : const Color(0xFFB0F1C3);

  // Status text (used over matching status surfaces)
  static Color get redDark =>
      _dark ? const Color(0xFFFCA5A5) : const Color(0xFFC10007);
  static Color get redDark2 =>
      _dark ? const Color(0xFFF87171) : const Color(0xFFE7000A);
  static Color get amberDark =>
      _dark ? const Color(0xFFFBBF24) : const Color(0xFFCC7A00);
  static Color get amberDark2 =>
      _dark ? const Color(0xFFFCD34D) : const Color(0xFFE2A000);
  static Color get greenDark =>
      _dark ? const Color(0xFF4ADE80) : const Color(0xFF17A34A);
  static Color get greenDark2 =>
      _dark ? const Color(0xFF4ADE80) : const Color(0xFF17A34A);
  static Color get yellowDark =>
      _dark ? const Color(0xFFFACC15) : const Color(0xFFA65F00);

  // Extra purple shade (settings overlay)
  static const Color purple500 = Color(0xFFAD46FF);
}

typedef DesignTokens = AppColors;
