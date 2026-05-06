import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page, RouteSettings? settings})
      : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Cubic(0.2, 0, 0, 1); // Premium ease-out
            
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0), // Slight slide-in
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: curve,
                )),
                child: child,
              ),
            );
          },
        );
}
