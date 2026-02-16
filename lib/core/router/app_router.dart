import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/login.dart';
import 'package:garbo_swms/presentation/citizen/pages/home_page.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/field_staff/pages/dashboard.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/home.dart';

class AppRouter {
  static const String login = '/login';
  static const String citizen = '/citizen';
  static const String collector = '/collector';
  static const String fieldStaff = '/field-staff';
  static const String thirdParty = '/third-party';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => Login());
      case citizen:
        return MaterialPageRoute(builder: (_) => CitizenHomePage());
      case collector:
        return MaterialPageRoute(builder: (_) => CollectionTeamDashboard());
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
