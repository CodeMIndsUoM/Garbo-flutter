import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';
import 'package:garbo_swms/presentation/auth/pages/change_password.dart';
import 'package:garbo_swms/presentation/citizen/pages/events.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/citizen/pages/profile.dart';
import 'package:garbo_swms/presentation/citizen/pages/report.dart';
import 'package:garbo_swms/presentation/citizen/pages/request.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/dashboard_page.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/home.dart';

class AppRouter {
  static const String login = '/login';
  static const String changePassword = '/change-password';
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
    final normalizedRole = rawRole?.trim().toUpperCase();
    if (normalizedRole == null || normalizedRole.isEmpty) {
      return null;
    }

    switch (normalizedRole) {
      case 'ROLE_CITIZEN':
      case 'CITIZEN':
        return citizenHome;
      case 'ROLE_BIN_COLLECTOR':
      case 'BIN_COLLECTOR':
      case 'ROLE_COLLECTOR':
      case 'COLLECTOR':
        return collectorDashboard;
      case 'ROLE_FIELD_MENTOR':
      case 'FIELD_MENTOR':
      case 'ROLE_FIELD_STAFF':
      case 'FIELD_STAFF':
        return fieldStaff;
      case 'ROLE_THIRD_PARTY_COLLECTOR':
      case 'THIRD_PARTY_COLLECTOR':
        return thirdParty;
      default:
        return null;
    }
  }

  static String routeForSession({String? token, String? role}) {
    if (token == null || token.isEmpty) {
      return login;
    }

    return routeForRole(role) ?? login;
  }

  static Widget pageForRoute(String routeName) {
    switch (routeName) {
      case login:
        return const Login();
      case changePassword:
        return const ChangePassword();
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
    return MaterialPageRoute(builder: (_) => pageForRoute(routeName));
  }
}
