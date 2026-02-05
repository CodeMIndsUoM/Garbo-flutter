import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/login.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Login(),
        ),
      ),
    );
  }
}
