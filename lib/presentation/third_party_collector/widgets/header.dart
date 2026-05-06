import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/widgets/premium/premium_header.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/data/models/collector_dashboard_model.dart';

class ThirdPartyHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const ThirdPartyHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  State<ThirdPartyHeader> createState() => _ThirdPartyHeaderState();
}

class _ThirdPartyHeaderState extends State<ThirdPartyHeader> {
  final ApiService _apiService = ApiService();
  CollectorDashboardModel? _dashboardModel;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final collectorId = await _apiService.getStoredEmpId();
      if (collectorId != null) {
        final dashboard = await _apiService.getCollectorDashboard(collectorId);
        if (mounted) {
          setState(() => _dashboardModel = dashboard);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PremiumHeader(
      title: widget.title,
      subtitle: widget.subtitle,
      stats: [
        PremiumStatItem(
          value: _dashboardModel?.availableRequests.toString() ?? '-',
          label: 'Available',
          icon: Icons.search_rounded,
        ),
        PremiumStatItem(
          value: _dashboardModel?.activeJobs.toString() ?? '-',
          label: 'Active',
          icon: Icons.work_outline_rounded,
        ),
        PremiumStatItem(
          value: _dashboardModel?.completedJobs.toString() ?? '-',
          label: 'Completed',
          icon: Icons.check_circle_outline_rounded,
        ),
      ],
      trailing: GestureDetector(
        onTap: widget.onNotificationTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white20,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
              if (widget.notificationCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red500,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.notificationCount > 9 ? '9+' : '${widget.notificationCount}',
                      textAlign: TextAlign.center,
                      style: AppTypography.badge,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
