import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/login.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbo SWMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arimo'),
      initialRoute: '/collector/routes', // Temporary for testing routes page
      routes: {
        '/login': (context) => Login(),
        '/citizen-home': (context) => CitizenHomePage(),
        '/collector/dashboard': (context) => CollectionTeamDashboard(),
        '/collector/routes': (context) => CollectionTeamRoutes(),
      },
    );
  }
}
