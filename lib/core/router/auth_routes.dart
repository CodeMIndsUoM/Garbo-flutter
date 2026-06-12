import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';

/// Route used when leaving the splash screen for login.
class AuthRoutes {
  static const splashToLoginDuration = Duration(milliseconds: 720);

  static Route<void> splashToLogin() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRouter.login),
      transitionDuration: splashToLoginDuration,
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppThemeSync(
          child: Login(enterAnimation: animation),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
