import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/app.dart';
import 'package:garbo_swms/core/services/firebase_bootstrap.dart';
import 'package:garbo_swms/data/sources/notification_api.dart';
import 'package:garbo_swms/data/sources/app_version_api.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:garbo_swms/presentation/providers/app_update_provider.dart';
import 'package:garbo_swms/presentation/providers/theme_provider.dart';
import 'package:garbo_swms/presentation/providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrapFirebase();

  final authProvider = AuthProvider();
  await authProvider.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AppUpdateProvider(
            api: AppVersionApi(client: http.Client()),
          )..initialize(),
        ),
        ChangeNotifierProvider.value(value: authProvider),

        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            return NotificationProvider(
              authProvider: auth,
              notificationApi: NotificationApi(
                client: http.Client(),
                authHeadersProvider: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token') ?? '';
                  return {
                    'Content-Type': 'application/json',
                    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
                  };
                },
              ),
            )..initialize();
          },
          update: (context, auth, notificationProvider) {
            final provider = notificationProvider!;
            provider.handleAuthChange(auth.isAuthenticated);
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, WebSocketProvider>(
          create: (context) => WebSocketProvider(context.read<AuthProvider>()),
          update: (context, authProvider, websocketProvider) =>
              websocketProvider ?? WebSocketProvider(authProvider),
        ),

        ChangeNotifierProxyProvider<WebSocketProvider, RouteProvider>(
          create: (context) => RouteProvider(context.read<WebSocketProvider>()),
          update: (context, wsProvider, routeProvider) =>
              routeProvider ?? RouteProvider(wsProvider),
        ),

        ChangeNotifierProxyProvider<WebSocketProvider, LeaderboardProvider>(
          create: (context) =>
              LeaderboardProvider(context.read<WebSocketProvider>()),
          update: (context, wsProvider, leaderboardProvider) =>
              leaderboardProvider ?? LeaderboardProvider(wsProvider),
        ),

        ChangeNotifierProxyProvider<
          WebSocketProvider,
          GamificationTasksProvider
        >(
          create: (_) => GamificationTasksProvider(),
          update: (context, wsProvider, gamificationProvider) {
            final provider =
                gamificationProvider ?? GamificationTasksProvider();
            provider.attachWebSocket(wsProvider);
            return provider;
          },
        ),
      ],
      child: const App(),
    ),
  );
}
