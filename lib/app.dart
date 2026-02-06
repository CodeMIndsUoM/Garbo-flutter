import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/login.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbo SWMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arimo'),
      initialRoute: '/collector/dashboard', // Temporary for testing
      routes: {
        '/login': (context) => Login(),
        '/citizen-home': (context) => CitizenHomePage(),
        '/collector/dashboard': (context) => CollectionTeamDashboard(),
      },
    );
  }
}
