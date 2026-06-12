import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/citizen/pages/report.dart';
import 'package:garbo_swms/presentation/citizen/pages/events.dart';
import 'package:garbo_swms/presentation/citizen/pages/request.dart';
import 'package:garbo_swms/presentation/citizen/pages/profile.dart';
import 'package:garbo_swms/presentation/shared/app_bottom_navigation.dart';

class CitizenBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const CitizenBottomNavbar({
    super.key,
    required this.currentIndex,
  });

  void onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final pages = <int, Widget>{
      0: const CitizenHomePage(),
      1: const CitizenReportPage(),
      2: const CitizenPublicEventsPage(),
      3: const CitizenRequestPage(),
      4: const CitizenProfilePage(),
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
      onTap: (index) => onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_problem_outlined),
          activeIcon: Icon(Icons.report_problem_rounded),
          label: 'Report',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event_rounded),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
