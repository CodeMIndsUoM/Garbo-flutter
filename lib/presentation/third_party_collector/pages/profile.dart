import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/edit_profile.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_expandable_section.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_logout_button.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_page_body.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_stats_section.dart';

import 'package:garbo_swms/data/models/collector_dashboard_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';

class ThirdPartyProfilePage extends StatefulWidget {
  const ThirdPartyProfilePage({super.key});

  @override
  State<ThirdPartyProfilePage> createState() => _ThirdPartyProfilePageState();
}

class _ThirdPartyProfilePageState extends State<ThirdPartyProfilePage> {
  final ApiService _apiService = ApiService();
  CollectorDashboardModel? _dashboardModel;
  String _empName = 'Collector';
  String _employeeId = '-';
  String _email = '-';
  String _joinedDate = '-';
  String? _avatarUrl;
  String? _company;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final collectorId = await _apiService.getStoredEmpId();
      if (collectorId.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final results = await Future.wait([
        _apiService.getCollectorDashboard(collectorId),
        _apiService.getThirdPartyCollectorProfile(collectorId),
      ]);

      final dashboard = results[0] as CollectorDashboardModel;
      final profile = results[1] as Map<String, dynamic>?;
      final name = (profile?['empName'] ?? '').toString();
      final email = (profile?['email'] ?? '').toString().trim();
      final createdAt = profile?['createdAt'] ?? profile?['created_at'];

      if (!mounted) return;
      setState(() {
        _dashboardModel = dashboard;
        _empName = name.isEmpty ? 'Collector' : name;
        _employeeId = collectorId;
        _email = email.isEmpty ? '-' : email;
        _avatarUrl = (profile?['avatarUrl'] as String?)?.trim();
        _company = (profile?['company'] as String?)?.trim();
        _joinedDate = _formatJoinedDate(createdAt);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatJoinedDate(dynamic rawCreatedAt) {
    if (rawCreatedAt == null) return '-';
    final value = rawCreatedAt.toString().trim();
    if (value.isEmpty) return '-';

    try {
      final parsed = DateTime.parse(value);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return '-';
    }
  }

  String _formatMinutes(int totalMinutes) {
    if (totalMinutes == 0) return '0h 0m';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.grey50,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.green700),
        ),
        bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 3),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const ThirdPartyHeader(title: 'Profile', subtitle: ''),
          Expanded(
            child: ProfilePageBody(
              profileCard: ProfileCard(
                name: _empName,
                role: _company ?? 'Third Party Collector',
                employeeId: _employeeId,
                email: _email,
                joinedDate: _joinedDate,
                avatarUrl: _avatarUrl,
                onEditTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ThirdPartyEditProfilePage(),
                    ),
                  );
                  if (mounted) await _loadProfileData();
                },
              ),
              sections: [
                ProfileStatsSection(
                  rows: [
                    ProfileStatRow(
                      label: 'Completed Jobs',
                      value: '${_dashboardModel?.completedJobs ?? 0}',
                    ),
                    ProfileStatRow(
                      label: 'Active Jobs',
                      value: '${_dashboardModel?.activeJobs ?? 0}',
                    ),
                    ProfileStatRow(
                      label: 'Average Rating',
                      value:
                          '${_dashboardModel?.overallRating.toStringAsFixed(1) ?? '0.0'} / 5.0',
                    ),
                    ProfileStatRow(
                      label: 'On-Time Rate',
                      value:
                          '${_dashboardModel?.onTimeRate.toStringAsFixed(0) ?? '0'}%',
                    ),
                  ],
                ),
                ProfileExpandableSection(
                  title: 'Earnings Overview',
                  icon: Icons.payments_outlined,
                  subtitle: "Today's impact & working hours",
                  child: _buildTodaysImpactCard(),
                ),
                ProfileExpandableSection(
                  title: 'Collector Details',
                  icon: Icons.badge_outlined,
                  subtitle: 'Jobs, ratings & response metrics',
                  child: _buildCollectorDetailsCard(),
                ),
              ],
              footer: const ProfileLogoutButton(
                dialogMessage:
                    "You'll need to sign in again to access your offers and jobs.",
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 3),
    );
  }

  Widget _buildTodaysImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Today's Impact",
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.amber600,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${_dashboardModel?.todaysRating.toStringAsFixed(1) ?? '0.0'} Today's Rating",
                      style: AppTypography.captionSm.copyWith(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildImpactStat(
                  value: _formatMinutes(
                    _dashboardModel?.todaysWorkingMinutes ?? 0,
                  ),
                  label: 'Working Hours',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImpactStat(
                  value:
                      '${_dashboardModel?.todaysWasteCollectedKg.toStringAsFixed(2) ?? '0.00'} Kg',
                  label: 'Waste Collected',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey100, width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Available Jobs',
            value: '${_dashboardModel?.availableRequests ?? 0}',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Completed Jobs',
            value: '${_dashboardModel?.completedJobs ?? 0}',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Active Jobs',
            value: '${_dashboardModel?.activeJobs ?? 0}',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Average Rating',
            value:
                '${_dashboardModel?.overallRating.toStringAsFixed(1) ?? '0.0'} / 5.0',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Reviews',
            value: '${_dashboardModel?.totalReviews ?? 0}',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Response Rate',
            value:
                '${_dashboardModel?.responseRate.toStringAsFixed(0) ?? '0'}%',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'On-Time Rate',
            value: '${_dashboardModel?.onTimeRate.toStringAsFixed(0) ?? '0'}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.titleMd.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTypography.titleMd.copyWith(
              color: AppColors.green700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(height: 1, color: AppColors.grey100),
    );
  }
}
