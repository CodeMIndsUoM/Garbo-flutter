import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';

/// Shared durations and curves for app navigation.
abstract final class AppTransitions {
  static const Duration page = Duration(milliseconds: 380);
  static const Duration reverse = Duration(milliseconds: 320);
  static const Duration tab = Duration(milliseconds: 300);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve fade = Cubic(0.22, 1, 0.36, 1);

  static Widget buildForward({
    required Animation<double> animation,
    required Widget child,
    Offset slideBegin = const Offset(0.04, 0),
  }) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: enter,
      reverseCurve: exit,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(
          curved,
        ),
        child: child,
      ),
    );
  }

  static Widget buildFade({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: fade,
        reverseCurve: exit,
      ),
      child: child,
    );
  }

  static Widget buildTabSwitch({
    required Animation<double> animation,
    required Widget child,
    required bool slideFromLeft,
  }) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: enter,
      reverseCurve: exit,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(slideFromLeft ? -0.05 : 0.05, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Default push transition for screens opened on top of another.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required Widget page,
    RouteSettings? settings,
    Offset slideBegin = const Offset(0.04, 0),
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              AppThemeSync(child: page),
          transitionDuration: AppTransitions.page,
          reverseTransitionDuration: AppTransitions.reverse,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppTransitions.buildForward(
              animation: animation,
              child: child,
              slideBegin: slideBegin,
            );
          },
        );
}

/// Cross-fade transition for bottom navigation tab changes.
class AppFadeRoute<T> extends PageRouteBuilder<T> {
  AppFadeRoute({
    required Widget page,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              AppThemeSync(child: page),
          transitionDuration: AppTransitions.tab,
          reverseTransitionDuration: AppTransitions.tab,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppTransitions.buildFade(
              animation: animation,
              child: child,
            );
          },
        );
}

/// Used by [MaterialApp.pageTransitionsTheme] for standard [MaterialPageRoute]s.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppTransitions.buildForward(animation: animation, child: child);
  }
}

@Deprecated('Use AppFadeRoute instead')
typedef SmoothPageRoute<T> = AppFadeRoute<T>;

extension AppNavigation on BuildContext {
  Future<T?> pushAppPage<T>(Widget page, {RouteSettings? settings}) {
    return Navigator.of(this).push<T>(
      AppPageRoute<T>(page: page, settings: settings),
    );
  }

  Future<T?> pushReplacementAppPage<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, T>(
      AppPageRoute<T>(page: page),
    );
  }

  Future<T?> pushFadeReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, T>(
      AppFadeRoute<T>(page: page),
    );
  }
}
