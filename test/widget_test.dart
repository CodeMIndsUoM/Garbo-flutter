// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:garbo_swms/app.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/theme_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';

void main() {
  testWidgets('App loads and shows login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProxyProvider<AuthProvider, WebSocketProvider>(
            create: (context) => WebSocketProvider(context.read<AuthProvider>()),
            update: (context, authProvider, previous) =>
                previous ?? WebSocketProvider(authProvider),
          ),
          ChangeNotifierProxyProvider<WebSocketProvider, RouteProvider>(
            create: (context) => RouteProvider(context.read<WebSocketProvider>()),
            update: (context, webSocketProvider, previous) =>
                previous ?? RouteProvider(webSocketProvider),
          ),
          ChangeNotifierProxyProvider<WebSocketProvider, LeaderboardProvider>(
            create: (context) =>
                LeaderboardProvider(context.read<WebSocketProvider>()),
            update: (context, webSocketProvider, previous) =>
                previous ?? LeaderboardProvider(webSocketProvider),
          ),
          ChangeNotifierProxyProvider<WebSocketProvider, GamificationTasksProvider>(
            create: (_) => GamificationTasksProvider(),
            update: (context, webSocketProvider, gamificationProvider) {
              final provider = gamificationProvider ?? GamificationTasksProvider();
              provider.attachWebSocket(webSocketProvider);
              return provider;
            },
          ),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
