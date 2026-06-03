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
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: SafeArea(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 72,
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) => _onTap(context, index),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.green700,
                  unselectedItemColor: AppColors.grey500,
                  selectedLabelStyle: AppTypography.labelSm,
                  unselectedLabelStyle: AppTypography.caption,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search_rounded),
                      activeIcon: Icon(Icons.search_rounded),
                      label: 'Browse',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.work_outline_rounded),
                      activeIcon: Icon(Icons.work_rounded),
                      label: 'My Jobs',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      activeIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
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

