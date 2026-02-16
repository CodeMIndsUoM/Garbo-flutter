import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:garbo_swms/core/router/app_router.dart';
=======
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/login.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes_page.dart';
>>>>>>> main

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbo SWMS',
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arimo'),
      initialRoute: AppRouter.fieldStaff, // Change this to test other roles
      onGenerateRoute: AppRouter.onGenerateRoute,
=======
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green700),
        fontFamily: 'Arimo',
      ),
      initialRoute: '/collector/dashboard',
      routes: {
        '/login': (context) => Login(),
        '/citizen-home': (context) => CitizenHomePage(),
        '/collector/dashboard': (context) => CollectionTeamDashboard(),
        '/collector/routes': (context) => CollectionTeamRoutes(),
      },
>>>>>>> main
    );
  }
}
