import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/edit_profile.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';

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
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.green700),
        ),
        bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 3),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'Profile',
            subtitle: '',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: ProfileCard(
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
                  ),

                  // Earnings Overview
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: AppColors.grey900, size: 20),
                        SizedBox(width: 8),
                        Text('Earnings Overview', style: AppTypography.titleLg),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTodaysImpactCard(),
                  ),
                  const SizedBox(height: 24),

                  // Collector Details
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(Icons.stars_outlined, color: AppColors.grey900, size: 20),
                        SizedBox(width: 8),
                        Text('Collector Details', style: AppTypography.titleLg),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildCollectorDetailsCard(),
                  ),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildLogoutButton(context),
                  ),
                  const SizedBox(height: 140), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 3),
    );
  }

  // ── Today's Impact Card ──────────────────────────────────────────────

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
                  style: AppTypography.titleMd.copyWith(color: AppColors.grey900, fontWeight: FontWeight.bold),
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
              Expanded(child: _buildImpactStat(value: _formatMinutes(_dashboardModel?.todaysWorkingMinutes ?? 0), label: 'Working Hours')),
              const SizedBox(width: 12),
              Expanded(child: _buildImpactStat(value: '${_dashboardModel?.todaysWasteCollectedKg.toStringAsFixed(2) ?? '0.00'} Kg', label: 'Waste Collected')),
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

  // ── Collector Details ────────────────────────────────────────────────

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
            value: '${_dashboardModel?.overallRating.toStringAsFixed(1) ?? '0.0'} / 5.0',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Reviews',
            value: '${_dashboardModel?.totalReviews ?? 0}',
          ),
          const _RowDivider(),
          _buildDetailRow(
            label: 'Response Rate',
            value: '${_dashboardModel?.responseRate.toStringAsFixed(0) ?? '0'}%',
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


  // ── Logout Button ────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red100, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmLogout(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.red500,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Log Out',
                  style: AppTypography.buttonMd.copyWith(
                    color: AppColors.red500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logout Flow ──────────────────────────────────────────────────────

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.red500,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Log out of your account?',
                textAlign: TextAlign.center,
                style: AppTypography.h4,
              ),
              const SizedBox(height: 6),
              Text(
                "You'll need to sign in again to access your offers and jobs.",
                textAlign: TextAlign.center,
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.of(ctx).pop(false),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: AppTypography.buttonMd.copyWith(
                              color: AppColors.grey700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: AppColors.red500,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.of(ctx).pop(true),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Log Out',
                            textAlign: TextAlign.center,
                            style: AppTypography.buttonMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    }
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
