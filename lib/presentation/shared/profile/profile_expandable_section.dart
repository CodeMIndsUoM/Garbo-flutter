import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Extra profile content — tap to expand inside the profile tab.
class ProfileExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final Widget child;
  final ValueChanged<bool>? onExpandedChanged;

  const ProfileExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.child,
    this.onExpandedChanged,
  });

  @override
  State<ProfileExpandableSection> createState() =>
      _ProfileExpandableSectionState();
}

class _ProfileExpandableSectionState extends State<ProfileExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                final next = !_expanded;
                setState(() => _expanded = next);
                if (next) {
                  widget.onExpandedChanged?.call(true);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(),
                child: Row(
                  children: [
                    Icon(widget.icon, color: AppColors.green700, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTypography.titleSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            widget.child,
          ],
        ],
      ),
    );
  }
}
