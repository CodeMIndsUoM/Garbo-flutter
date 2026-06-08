import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String employeeId;
  final String email;
  final String joinedDate;
  final String? avatarUrl;
  final VoidCallback? onEditTap;
  final bool showInfoChips;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.employeeId,
    required this.email,
    required this.joinedDate,
    this.avatarUrl,
    this.onEditTap,
    this.showInfoChips = true,
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
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Round Profile Icon with camera badge
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            width: 76,
                            height: 76,
                            errorBuilder: (_, __, ___) => Text(
                              _initials,
                              style: AppTypography.displayLg.copyWith(
                                color: AppColors.grey900,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Text(
                            _initials,
                            style: AppTypography.displayLg.copyWith(
                              color: AppColors.grey900,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: onEditTap,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.green700,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowSm,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.grey900,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(role, style: AppTypography.bodySm.copyWith(color: AppColors.grey600)),
                    const SizedBox(height: 2),
                    Text('ID: $employeeId', style: AppTypography.captionSm.copyWith(color: AppColors.grey500)),
                  ],
                ),
              ),
              // Edit Icon at the right top corner of this section
              if (onEditTap != null)
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.grey500,
                    size: 22,
                  ),
                  onPressed: onEditTap,
                  tooltip: 'Edit Profile',
                ),
            ],
          ),
          if (showInfoChips) ...[
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
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.overline.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.captionSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
