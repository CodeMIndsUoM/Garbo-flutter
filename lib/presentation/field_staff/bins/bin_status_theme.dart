import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

/// Shared fill-status colors for field-staff bin UI.
abstract final class BinStatusTheme {
  static Color accent(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey300;
      case BinStatus.full:
        return AppColors.red500;
      case BinStatus.half:
        return AppColors.yellow400;
      case BinStatus.empty:
        return AppColors.green700;
    }
  }

  static Color text(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.blue600;
      case BinStatus.full:
        return AppColors.red500;
      case BinStatus.half:
        return AppColors.yellowDark;
      case BinStatus.empty:
        return AppColors.green700;
    }
  }

  static Color surface(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.blue50;
      case BinStatus.full:
        return AppColors.redSurface2;
      case BinStatus.half:
        return AppColors.yellow;
      case BinStatus.empty:
        return AppColors.greenSurface2;
    }
  }

  static Color badgeBackground(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey100;
      case BinStatus.full:
        return AppColors.redSurface2;
      case BinStatus.half:
        return AppColors.yellow;
      case BinStatus.empty:
        return AppColors.greenSurface2;
    }
  }

  static Color cardBackground(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.surface;
      case BinStatus.full:
        return AppColors.redSurface2;
      case BinStatus.half:
        return AppColors.yellow;
      case BinStatus.empty:
        return AppColors.greenSurface3;
    }
  }

  static Color cardBorder(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey200;
      case BinStatus.full:
        return AppColors.red100;
      case BinStatus.half:
        return AppColors.yellow400.withValues(alpha: 0.45);
      case BinStatus.empty:
        return AppColors.greenBorder2;
    }
  }

  static Color cardText(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.citizenGrey500;
      case BinStatus.full:
        return AppColors.redDark2;
      case BinStatus.half:
        return AppColors.yellowDark;
      case BinStatus.empty:
        return AppColors.greenDark2;
    }
  }

  static Color reportOptionColor(BinStatus status) {
    switch (status) {
      case BinStatus.empty:
        return AppColors.green700;
      case BinStatus.half:
        return AppColors.yellowDark;
      case BinStatus.full:
        return AppColors.red500;
      case BinStatus.notChecked:
        return AppColors.grey600;
    }
  }

  static Color reportOptionBackground(BinStatus status) {
    switch (status) {
      case BinStatus.empty:
        return AppColors.emerald50;
      case BinStatus.half:
        return AppColors.yellow;
      case BinStatus.full:
        return AppColors.red50;
      case BinStatus.notChecked:
        return AppColors.surfaceVariant;
    }
  }
}
