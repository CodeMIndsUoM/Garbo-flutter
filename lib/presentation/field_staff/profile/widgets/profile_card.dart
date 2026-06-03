import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String employeeId;
  final String email;
  final String joinedDate;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.employeeId,
    required this.email,
    required this.joinedDate,
  });

  String get _initials {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 10,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(_initials, style: AppTypography.displayLg.copyWith(color: AppColors.grey900)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.h2.copyWith(color: AppColors.grey900)),
                    const SizedBox(height: 2),
                    Text(role, style: AppTypography.bodySm.copyWith(color: AppColors.grey600)),
                    const SizedBox(height: 2),
                    Text('ID: $employeeId', style: AppTypography.captionSm.copyWith(color: AppColors.grey500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  label: 'Email',
                  value: email,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  label: 'Joined',
                  value: joinedDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.overline.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0, color: AppColors.grey600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.captionSm.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
