import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';

/// Shared profile scroll body — profile card + sections + bottom spacing.
class ProfilePageBody extends StatelessWidget {
  final ProfileCard profileCard;
  final List<Widget> sections;
  final Widget? footer;

  const ProfilePageBody({
    super.key,
    required this.profileCard,
    required this.sections,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey50,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: profileCard,
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < sections.length; i++) ...[
              sections[i],
              if (i < sections.length - 1) const SizedBox(height: 24),
            ],
            if (footer != null) ...[
              const SizedBox(height: 24),
              footer!,
            ],
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}
