import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';
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
  static const String citizenHome = '/citizen-home';
  static const String citizenReport = '/citizen/report';
  static const String citizenRequest = '/citizen/request';
  static const String citizenEvents = '/citizen/events';
  static const String citizenProfile = '/citizen/profile';
  static const String collectorDashboard = '/collector/dashboard';
  static const String collectorRoutes = '/collector/routes';
  static const String fieldStaff = '/field-staff';
  static const String thirdParty = '/third-party';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => Login());
      case citizenHome:
        return MaterialPageRoute(builder: (_) => CitizenHomePage());
      case citizenReport:
        return MaterialPageRoute(builder: (_) => CitizenReportPage());
      case citizenRequest:
        return MaterialPageRoute(builder: (_) => CitizenRequestPage());
      case citizenEvents:
        return MaterialPageRoute(builder: (_) => CitizenPublicEventsPage());
      case citizenProfile:
        return MaterialPageRoute(builder: (_) => CitizenProfilePage());
      case collectorDashboard:
        return MaterialPageRoute(builder: (_) => CollectionTeamDashboard());
      case collectorRoutes:
        return MaterialPageRoute(builder: (_) => CollectionTeamRoutes());
      case fieldStaff:
        return MaterialPageRoute(builder: (_) => Dashboard());
      case thirdParty:
        return MaterialPageRoute(builder: (_) => ThirdPartyHome());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
