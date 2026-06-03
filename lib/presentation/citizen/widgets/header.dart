import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/pages/settings.dart';

class CitizenHeader extends StatelessWidget {
  final String name;
  final String? profileImageUrl;

  const CitizenHeader({super.key, required this.name, this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        18,
      ),
      decoration: const BoxDecoration(color: AppColors.grey50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: AppTypography.h1.copyWith(color: AppColors.grey900),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CitizenSettingsPage(),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu, color: AppColors.grey900),
            ),
          ),
        ],
      ),
    );
  }
}
