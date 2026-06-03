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
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: -8,
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
                    onTap: () => onTap(context, i),
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
                                ? AppColors.emerald700
                                : AppColors.citizenGrey500,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
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

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}
