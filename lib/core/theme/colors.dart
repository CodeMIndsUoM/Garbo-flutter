import 'package:flutter/material.dart';

extension MaterialColorExtension on Colors {
  static MaterialColor get emerald =>
      const MaterialColor(0xFF059669, <int, Color>{
        50: Color(0xFFECFDF5),
        100: Color(0xFFD1FAE5),
        200: Color(0xFFA7F3D0),
        300: Color(0xFF6EE7B7),
        400: Color(0xFF34D399),
        500: Color(0xFF10B981),
        600: Color(0xFF059669),
        700: Color(0xFF047857),
        800: Color(0xFF065F46),
        900: Color(0xFF064E3B),
      });

  static MaterialColor get teal => const MaterialColor(0xFF0D9488, <int, Color>{
    50: Color(0xFFF0FDFA),
    100: Color(0xFFCCFBF1),
    200: Color(0xFF99F6E4),
    300: Color(0xFF5EEAD4),
    400: Color(0xFF2DD4BF),
    500: Color(0xFF14B8A6),
    600: Color(0xFF0D9488),
    700: Color(0xFF0F766E),
    800: Color(0xFF115E59),
    900: Color(0xFF134E4A),
  });
}
