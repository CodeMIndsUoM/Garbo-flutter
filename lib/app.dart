import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class App extends StatelessWidget {
  const App({super.key});

  static const _green = AppColors.green700;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _green,
      primary: _green,
      onPrimary: Colors.white,
      primaryContainer: AppColors.emerald100,
      onPrimaryContainer: _green,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Garbo SWMS',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoScrollbarBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _green,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _green.withValues(alpha: 0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return _green;
              return Colors.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return _green;
            }),
            side: WidgetStateProperty.all(
              BorderSide(color: _green.withValues(alpha: 0.35)),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _green,
            side: BorderSide(color: _green.withValues(alpha: 0.5)),
          ),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(4),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(AppColors.shadowSm),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.grey200, width: 1.2),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: _green,
          headerForegroundColor: Colors.white,
          headerHeadlineStyle: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
          headerHelpStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          weekdayStyle: const TextStyle(
            color: AppColors.grey600,
            fontSize: 13,
          ),
          dayStyle: const TextStyle(
            color: AppColors.grey900,
            fontSize: 14,
          ),
          yearStyle: const TextStyle(color: AppColors.grey900),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            if (states.contains(WidgetState.disabled)) return AppColors.grey400;
            return AppColors.grey900;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _green;
            return Colors.transparent;
          }),
          todayForegroundColor: const WidgetStatePropertyAll(_green),
          todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          todayBorder: const BorderSide(color: _green, width: 1.5),
          confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: _green,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: _green,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _green.withValues(alpha: 0.35)),
          ),
          dayPeriodColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _green;
            return AppColors.greenSurface2;
          }),
          dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return _green;
          }),
          dialHandColor: _green,
          dialBackgroundColor: AppColors.greenSurface2,
          entryModeIconColor: _green,
          confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: _green,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: _green,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
