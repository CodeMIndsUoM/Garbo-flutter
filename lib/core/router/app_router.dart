import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';
import 'package:garbo_swms/presentation/auth/pages/change_password.dart';
import 'package:garbo_swms/presentation/auth/pages/splash_screen.dart';
import 'package:garbo_swms/presentation/citizen/pages/events.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/citizen/pages/profile.dart';
import 'package:garbo_swms/presentation/citizen/pages/report.dart';
import 'package:garbo_swms/presentation/citizen/pages/request.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/dashboard_page.dart';
import 'package:garbo_swms/presentation/auth/pages/third_party_set_password.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/home.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String changePassword = '/change-password';
  static const String thirdPartySetPassword = '/third-party/set-password';
  static const String citizenHome = '/citizen-home';
  static const String citizenReport = '/citizen/report';
  static const String citizenRequest = '/citizen/request';
  static const String citizenEvents = '/citizen/events';
  static const String citizenProfile = '/citizen/profile';
  static const String collectorDashboard = '/collector/dashboard';
  static const String collectorRoutes = '/collector/routes';
  static const String fieldStaff = '/field-staff';
  static const String thirdParty = '/third-party';

  static String? routeForRole(String? rawRole) {
    if (rawRole == null || rawRole.trim().isEmpty) {
      return null;
    }

    var normalizedRole = rawRole.trim().toUpperCase().replaceAll('-', '_');
    if (normalizedRole.startsWith('ROLE_')) {
      normalizedRole = normalizedRole.substring(5);
    }

    switch (normalizedRole) {
      case 'CITIZEN':
        return citizenHome;
      case 'BIN_COLLECTOR':
      case 'COLLECTOR':
        return collectorDashboard;
      case 'FIELD_MENTOR':
      case 'FIELD_STAFF':
        return fieldStaff;
      case 'THIRD_PARTY_COLLECTOR':
        return thirdParty;
      default:
        return null;
    }
  }

  static String routeForSession({
    String? token,
    String? role,
    String? lastRoute,
  }) {
    if (token == null || token.isEmpty) {
      return login;
    }

    final route = routeForRole(role);
    if (route != null) {
      return route;
    }

    if (lastRoute != null &&
        lastRoute.isNotEmpty &&
        lastRoute != login &&
        lastRoute != splash) {
      return lastRoute;
    }

    return login;
  }

  static Widget pageForRoute(String routeName) {
    switch (routeName) {
      case splash:
        return const SplashScreen();
      case login:
        return const Login();
      case changePassword:
        return const ChangePassword();
      case thirdPartySetPassword:
        return const Login();
      case citizenHome:
        return const CitizenHomePage();
      case citizenReport:
        return const CitizenReportPage();
      case citizenRequest:
        return const CitizenRequestPage();
      case citizenEvents:
        return const CitizenPublicEventsPage();
      case citizenProfile:
        return const CitizenProfilePage();
      case collectorDashboard:
        return const CollectionTeamDashboard();
      case collectorRoutes:
        return const CollectionTeamRoutes();
      case fieldStaff:
        return const Dashboard();
      case thirdParty:
        return const ThirdPartyHome();
      default:
        return Scaffold(
          body: Center(child: Text('No route defined for $routeName')),
        );
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? login;

    if (routeName == thirdPartySetPassword) {
      final args = settings.arguments;
      if (args is Map<String, dynamic>) {
        final empId = args['empId'];
        final email = args['email']?.toString() ?? '';
        final parsedId = empId is int ? empId : int.tryParse('$empId') ?? 0;
        return AppPageRoute(
          page: ThirdPartySetPasswordPage(
            empId: parsedId,
            email: email,
          ),
          settings: settings,
        );
      }
    }

    return AppPageRoute(
      page: pageForRoute(routeName),
      settings: settings,
    );
  }
}
