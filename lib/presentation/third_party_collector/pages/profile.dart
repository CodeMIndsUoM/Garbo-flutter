import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/auth/pages/login.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/app_settings.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/edit_profile.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';

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

      if (!mounted) return;
      setState(() {
        _dashboardModel = dashboard;
        _empName = name.isEmpty ? 'Collector' : name;
        _avatarUrl = (profile?['avatarUrl'] as String?)?.trim();
        _company = (profile?['company'] as String?)?.trim();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _reviewCountLabel() {
    final count = _dashboardModel?.totalReviews ?? 0;
    return '$count review${count == 1 ? '' : 's'}';
  }

  String _memberSinceLabel() {
    final date = _dashboardModel?.memberSince?.toLocal();
    if (date == null) return 'Member since —';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Member since ${months[date.month - 1]} ${date.year}';
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Earnings Overview'),
                const SizedBox(height: 12),
                _buildTodaysImpactCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Collector Details'),
                const SizedBox(height: 12),
                _buildCollectorDetailsCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Settings'),
                const SizedBox(height: 12),
                _buildSettingsCard(context),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 3),
    );
  }

  // ── Profile Header ───────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 18,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.grey200,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? Image.network(
                        _avatarUrl!,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        cacheWidth: 240,
                        cacheHeight: 240,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.grey600,
                          size: 40,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.grey600,
                        size: 40,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _empName,
                      style: AppTypography.h2.copyWith(color: AppColors.grey900),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.amber600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dashboardModel?.overallRating.toStringAsFixed(1) ?? '0.0',
                          style: AppTypography.titleSm.copyWith(
                            color: AppColors.grey900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${_reviewCountLabel()}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _memberSinceLabel(),
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    if (_company != null && _company!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _company!,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildHeaderStat(value: '${_dashboardModel?.availableRequests ?? 0}', label: 'Available jobs')),
              const SizedBox(width: 10),
              Expanded(child: _buildHeaderStat(value: '${_dashboardModel?.completedJobs ?? 0}', label: 'Completed jobs')),
              const SizedBox(width: 10),
              Expanded(child: _buildHeaderStat(value: '${_dashboardModel?.activeJobs ?? 0}', label: 'Active jobs')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.displaySm.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: AppTypography.labelSm.copyWith(color: AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.h3);
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
            offset: Offset(0, 4),
            blurRadius: 10,
            spreadRadius: -3,
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
                  style: AppTypography.h3.copyWith(color: AppColors.grey900),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.star_border_rounded,
            label: 'Average Rating',
            value:
                '${_dashboardModel?.overallRating.toStringAsFixed(1) ?? '0.0'} / 5.0',
          ),
          const _RowDivider(),
          _buildDetailRow(
            icon: Icons.rate_review_outlined,
            label: 'Reviews',
            value: '${_dashboardModel?.totalReviews ?? 0}',
          ),
          const _RowDivider(),
          _buildDetailRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Response Rate',
            value: '${_dashboardModel?.responseRate.toStringAsFixed(0) ?? '0'}%',
          ),
          const _RowDivider(),
          _buildDetailRow(
            icon: Icons.schedule_rounded,
            label: 'On-Time Rate',
            value: '${_dashboardModel?.onTimeRate.toStringAsFixed(0) ?? '0'}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.green700, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodySm),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Settings ─────────────────────────────────────────────────────────

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ThirdPartyEditProfilePage(),
                ),
              );
              if (mounted) await _loadProfileData();
            },
          ),
          const _RowDivider(),
          _buildSettingsRow(
            icon: Icons.settings_outlined,
            label: 'App Settings',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ThirdPartyAppSettingsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.green700, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logout Button ────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _confirmLogout(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.red100, width: 1),
          ),
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
      padding: const EdgeInsets.only(left: 70),
      child: Container(height: 1, color: AppColors.grey100),
    );
  }
}
