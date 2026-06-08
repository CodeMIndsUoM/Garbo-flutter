import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/providers/theme_provider.dart';

/// Resolves the effective brightness from [mode] and the device setting.
Brightness resolveAppBrightness(BuildContext context, ThemeMode mode) {
  final platform = MediaQuery.platformBrightnessOf(context);
  return switch (mode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => platform,
  };
}

/// Syncs [AppColors.brightness] and registers this widget to rebuild when the
/// theme mode changes. Call at the top of any [build] that reads [AppColors].
Brightness syncAppColorsFromContext(BuildContext context) {
  final mode = context.watch<ThemeProvider>().mode;
  final brightness = resolveAppBrightness(context, mode);
  AppColors.brightness = brightness;
  return brightness;
}

/// Sits above the navigator in [MaterialApp.builder] to keep [AppColors] in
/// sync whenever the theme mode changes.
class AppThemeBinder extends StatelessWidget {
  final Widget child;

  const AppThemeBinder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);
    return child;
  }
}

/// Wraps a route/screen so it rebuilds when the user changes theme mode.
///
/// Most screens read [AppColors] directly (not [Theme.of]), so they must
/// re-run [build] after a theme toggle.
class AppThemeSync extends StatelessWidget {
  final Widget child;

  const AppThemeSync({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mode = syncAppColorsFromContext(context);

    return KeyedSubtree(
      key: ValueKey(mode),
      child: child,
    );
  }
}

/// Builds a [MaterialPageRoute] whose page rebuilds on theme changes.
Route<T> themedMaterialRoute<T>(Widget page) {
  return MaterialPageRoute<T>(
    builder: (_) => AppThemeSync(child: page),
  );
}
