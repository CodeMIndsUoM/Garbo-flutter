import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbo SWMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green700),
        fontFamily: 'Arimo',
      ),
      // Quick switch for UI testing:
      // AppRouter.login
      // AppRouter.citizenHome
      // AppRouter.citizenReport
      // AppRouter.citizenRequest
      // AppRouter.citizenEvents
      // AppRouter.citizenProfile
      // AppRouter.collectorDashboard
      // AppRouter.collectorRoutes
      // AppRouter.fieldStaff
      // AppRouter.thirdParty
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
