import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/app.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        /// Auth provider must come first as other providers depend on it
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        /// WebSocket provider depends on Auth provider
        ChangeNotifierProxyProvider<AuthProvider, WebSocketProvider>(
          create: (context) => WebSocketProvider(context.read<AuthProvider>()),
          update: (context, authProvider, websocketProvider) =>
              websocketProvider ?? WebSocketProvider(authProvider),
        ),
        
        /// Route provider depends on WebSocket provider
        ChangeNotifierProxyProvider<WebSocketProvider, RouteProvider>(
          create: (context) => RouteProvider(context.read<WebSocketProvider>()),
          update: (context, wsProvider, routeProvider) =>
              routeProvider ?? RouteProvider(wsProvider),
        ),
        
        /// Leaderboard provider depends on WebSocket provider
        ChangeNotifierProxyProvider<WebSocketProvider, LeaderboardProvider>(
          create: (context) => LeaderboardProvider(context.read<WebSocketProvider>()),
          update: (context, wsProvider, leaderboardProvider) =>
              leaderboardProvider ?? LeaderboardProvider(wsProvider),
        ),
        
        /// Gamification tasks provider for achievement tracking
        ChangeNotifierProxyProvider<WebSocketProvider, GamificationTasksProvider>(
          create: (_) => GamificationTasksProvider(),
          update: (context, wsProvider, gamificationProvider) {
            final provider = gamificationProvider ?? GamificationTasksProvider();
            provider.attachWebSocket(wsProvider);
            return provider;
          },
        ),
      ],
      child: const App(),
    ),
  );
}
