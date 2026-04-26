import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class FieldBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FieldBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: AppColors.grey200)),
      ),
        child: SizedBox(
        height: 100, // Sufficient height for icon + label + safe area
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.green700,
          unselectedItemColor: AppColors.grey500,
          selectedLabelStyle: AppTypography.labelSm,
          unselectedLabelStyle: AppTypography.caption,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline),
              activeIcon: Icon(Icons.delete),
              label: 'Bins',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),

    );
  }
}
