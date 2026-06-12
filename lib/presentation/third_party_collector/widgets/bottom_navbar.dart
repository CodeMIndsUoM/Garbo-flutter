import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
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
      context.pushFadeReplacement(page);
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
