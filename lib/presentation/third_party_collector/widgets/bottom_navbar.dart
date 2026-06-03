import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/home.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/browse.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/profile.dart';

class ThirdPartyBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const ThirdPartyBottomNavbar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final pages = <int, Widget>{
      0: const ThirdPartyHome(),
      1: const ThirdPartyBrowsePage(),
      2: const ThirdPartyMyJobsPage(),
      3: const ThirdPartyProfilePage(),
    };

    final page = pages[index];
    if (page != null) {
      Navigator.of(context).pushReplacement(SmoothPageRoute(page: page));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, 'Home'),
      _NavItem(Icons.search_rounded, 'Browse'),
      _NavItem(Icons.work_outline_rounded, 'My Jobs'),
      _NavItem(Icons.person_outline_rounded, 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.grey200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, -4),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: SizedBox(
            height: 72,
            child: Row(
              children: List.generate(items.length, (i) {
                final isSelected = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(context, i),
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.emerald50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].icon,
                            color: isSelected
                                ? AppColors.green700
                                : AppColors.grey400,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].label,
                            style: AppTypography.captionSm.copyWith(
                              color: isSelected
                                  ? AppColors.green700
                                  : AppColors.grey400,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.22, 1, 0.36, 1),
            ),
            child: child,
          );
        },
      );
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem(this.icon, this.label);
}
