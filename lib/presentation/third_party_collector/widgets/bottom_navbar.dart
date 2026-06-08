import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/home.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/browse.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/profile.dart';
import 'package:garbo_swms/presentation/shared/app_bottom_navigation.dart';

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
    return AppBottomNavigation(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
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
