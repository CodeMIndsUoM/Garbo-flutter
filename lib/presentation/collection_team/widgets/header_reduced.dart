import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/widgets/notifications_page.dart';

class HeaderReduced extends StatelessWidget {
  final String title;

  const HeaderReduced({super.key, this.title = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: title == 'Profile' ? Colors.white : AppColors.grey50,
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.h1.copyWith(color: AppColors.grey900),
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
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: const Icon(Icons.notifications_outlined, color: AppColors.grey900),
            ),
          ),
        ],
      ),
    );
  }
}
