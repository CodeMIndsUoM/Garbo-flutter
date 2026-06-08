import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

/// Icon and status-tag colors for citizen complaint/report cards.
({Color iconColor, Color tagBg, Color tagText}) complaintStatusStyle(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED':
    case 'ACCEPTED':
    case 'RESOLVED':
      return (
        iconColor: AppColors.green700,
        tagBg: AppColors.emerald100,
        tagText: AppColors.emerald700,
      );
    case 'REJECTED':
      return (
        iconColor: AppColors.redDark2,
        tagBg: AppColors.redSurface2,
        tagText: AppColors.redDark2,
      );
    case 'PENDING':
      return (
        iconColor: AppColors.amber600,
        tagBg: AppColors.amberSurface2,
        tagText: AppColors.amberDark,
      );
    default:
      return (
        iconColor: AppColors.grey600,
        tagBg: AppColors.grey100,
        tagText: AppColors.grey700,
      );
  }
}
