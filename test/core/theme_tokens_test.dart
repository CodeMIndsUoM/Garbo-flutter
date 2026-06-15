import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

void main() {
  group('AppColors palette', () {
    test('primary brand greens use the canonical hex values', () {
      expect(AppColors.green700, const Color(0xFF17A34A));
      expect(AppColors.green800, const Color(0xFF17A34A));
    });

    test('shadow tokens use black with documented opacity', () {
      expect(AppColors.shadowXs, const Color(0x0A000000));
      expect(AppColors.shadowSm, const Color(0x19000000));
      expect(AppColors.shadowMd, const Color(0x1F000000));
      expect(AppColors.scrim, const Color(0x66000000));
    });

    test('grey scale tokens are defined', () {
      expect(AppColors.grey50, isNotNull);
      expect(AppColors.grey900, isNotNull);
      expect(AppColors.grey50, isNot(equals(AppColors.grey900)));
    });
  });

  group('AppTypography scale', () {
    test('display, heading and title sizes follow the scale', () {
      expect(AppTypography.displayLg.fontSize, 28);
      expect(AppTypography.h1.fontSize, 24);
      expect(AppTypography.h2.fontSize, 20);
      expect(AppTypography.h3.fontSize, 18);
      expect(AppTypography.titleLg.fontSize, 16);
    });

    test('body and caption styles use the expected weights', () {
      expect(AppTypography.bodyLg.fontWeight, FontWeight.w400);
      expect(AppTypography.bodyMd.fontWeight, FontWeight.w400);
      expect(AppTypography.titleLg.fontWeight, FontWeight.w700);
      expect(AppTypography.caption.fontWeight, FontWeight.w400);
    });

    test('headings inherit the canonical text colour', () {
      expect(AppTypography.h1.color, AppColors.grey900);
      expect(AppTypography.h2.color, AppColors.grey900);
      expect(AppTypography.titleLg.color, AppColors.grey900);
    });
  });
}
