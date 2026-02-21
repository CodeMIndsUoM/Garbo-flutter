import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/citizen/pages/report.dart';
import 'package:garbo_swms/presentation/citizen/pages/events.dart';
import 'package:garbo_swms/presentation/citizen/pages/request.dart';
import 'package:garbo_swms/presentation/citizen/pages/profile.dart';

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
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(page: page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      NavItem(Icons.home_rounded, 'Home'),
      NavItem(Icons.report_problem_rounded, 'Report'),
      NavItem(Icons.event_rounded, 'Events'),
      NavItem(Icons.receipt_long_rounded, 'Requests'),
      NavItem(Icons.person_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(context, i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 32 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.emerald700
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        items[i].icon,
                        color: isSelected
                            ? AppColors.emerald700
                            : AppColors.citizenGrey500,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.emerald700
                              : AppColors.citizenGrey500,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}