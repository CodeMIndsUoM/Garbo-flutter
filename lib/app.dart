import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbo SWMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Arimo'),
      initialRoute: AppRouter.fieldStaff, // Change this to test other roles
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
