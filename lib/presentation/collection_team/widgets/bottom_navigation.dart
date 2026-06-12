import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/map.dart';
import 'package:garbo_swms/presentation/collection_team/pages/profile.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes.dart';
import 'package:garbo_swms/presentation/shared/app_bottom_navigation.dart';

class CollectionTeamBottomNav extends StatelessWidget {
  final int currentIndex;

  const CollectionTeamBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final pages = <int, Widget>{
      0: const CollectionTeamDashboard(),
      1: const CollectionTeamRoutes(),
      2: const CollectionTeamMap(),
      3: const CollectionTeamProfile(),
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
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          activeIcon: Icon(Icons.route_rounded),
          label: 'Routes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map_rounded),
          label: 'Map',
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
