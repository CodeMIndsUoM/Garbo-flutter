import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/leaderboard.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/citizen-home': (context) => CitizenHomePage(),
        // '/citizen/report': (context) => CitizenReportPage(),
        // '/citizen/request': (context) => CitizenRequestPage(),
        // '/citizen/events': (context) => CitizenPublicEventsPage(),
        // '/citizen/profile': (context) => CitizenProfilePage(),
        '/collector/dashboard': (context) => CollectionTeamDashboard(),
        '/collector/leaderboard': (context) => LeaderboardPage(),
        // '/collector/routes': (context) => CollectionTeamRoutes(),
      },
    );
  }
}
