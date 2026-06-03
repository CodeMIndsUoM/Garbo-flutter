import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/widgets/notifications_page.dart';

class StatHeader extends StatelessWidget {
  final String title;
  final String userName;
  final int toCheckCount;
  final int dayStreak;
  final String avgResponseLabel;

  const StatHeader({
    super.key,
    this.title = 'Field Staff',
    this.userName = 'Field Staff',
    this.toCheckCount = 0,
    this.dayStreak = 0,
    this.avgResponseLabel = '--',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: title == 'Profile' ? Colors.white : AppColors.grey50),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 10,
        24,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h1.copyWith(color: AppColors.grey900),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.grey900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
