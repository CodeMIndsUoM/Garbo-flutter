import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/collection_team/pages/settings.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';
import 'package:garbo_swms/presentation/widgets/websocket_status_dot.dart';
import 'package:garbo_swms/presentation/widgets/premium/premium_header.dart';
import 'package:provider/provider.dart';

class HeaderReduced extends StatelessWidget {
  const HeaderReduced({super.key});

  String _resolveFirstName(String? fullName) {
    final normalized = (fullName ?? '').trim();
    if (normalized.isEmpty) {
      return 'Collector';
    }
    return normalized.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final routeProvider = context.watch<RouteProvider>();
    final currentUser = authProvider.currentUser;
    final firstName = _resolveFirstName(currentUser?.empName);

    // Calculate stats for the header
    final now = DateTime.now();
    final sessionsToday = routeProvider.routeHistory
        .where((s) => 
          s.generatedAt.year == now.year && 
          s.generatedAt.month == now.month && 
          s.generatedAt.day == now.day
        ).toList();
    
    final collectedCount = sessionsToday.fold<int>(0, (sum, s) => sum + routeProvider.getCollectedCount(s.sessionId));
    final totalStops = sessionsToday.fold<int>(0, (sum, s) => sum + s.totalStops);

    return PremiumHeader(
      title: 'Collection Team',
      subtitle: 'Hello, $firstName!',
      stats: [
        PremiumStatItem(
          value: '$collectedCount',
          label: 'Collected',
          icon: Icons.delete_outline_rounded,
        ),
        PremiumStatItem(
          value: '$totalStops',
          label: 'Total Stops',
          icon: Icons.map_outlined,
        ),
        const PremiumStatItem(
          value: '85%',
          label: 'Efficiency',
          icon: Icons.trending_up_rounded,
        ),
      ],
      trailing: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white20,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            ),
            const Positioned(
              right: -2,
              top: -2,
              child: WebSocketStatusDot(size: 11),
            ),
          ],
        ),
      ),
    );
  }
}
