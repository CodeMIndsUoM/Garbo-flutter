import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/widgets/premium/premium_card.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => CitizenHomePageState();
}

class CitizenHomePageState extends State<CitizenHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildSectionHeader('Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildSectionHeader('Recent Activity'),
            const SizedBox(height: 12),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildTipCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTypography.titleLg);
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: PremiumCard(
            bgColor: AppColors.green700.withValues(alpha: 0.08),
            icon: Icons.eco_outlined,
            title: '145',
            subtitle: 'Total Points',
            themeColor: AppColors.green700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumCard(
            bgColor: AppColors.blue50,
            icon: Icons.auto_graph_outlined,
            title: 'Level 4',
            subtitle: 'Environment Hero',
            themeColor: AppColors.blue600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          icon: Icons.report_problem_rounded,
          title: 'Report Issue',
          subtitle: 'File a complaint',
          routeName: AppRouter.citizenReport,
        ),
        _buildActionCard(
          icon: Icons.local_shipping_rounded,
          title: 'Request Pickup',
          subtitle: 'Schedule collection',
          routeName: AppRouter.citizenRequest,
        ),
        _buildActionCard(
          icon: Icons.event_rounded,
          title: 'Browse Events',
          subtitle: 'Join community',
          routeName: AppRouter.citizenEvents,
        ),
        _buildActionCard(
          icon: Icons.bar_chart_rounded,
          title: 'My Activity',
          subtitle: 'Track progress',
          routeName: AppRouter.citizenProfile,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != routeName) {
            Navigator.pushNamed(context, routeName);
          }
        },
        child: PremiumCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleSm,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _buildActivityItem(
          icon: Icons.check_circle_rounded,
          title: 'Collection completed',
          subtitle: 'Recyclable materials picked up',
          time: '2 hours ago',
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.event_available_rounded,
          title: 'Event enrolled',
          subtitle: 'Community Cleanup Drive',
          time: '1 day ago',
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.green700.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMd),
                Text(subtitle, style: AppTypography.bodySm),
                const SizedBox(height: 4),
                Text(time, style: AppTypography.overline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green700.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green700.withValues(alpha: 0.1), width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waste Management Tip',
                  style: AppTypography.titleMd.copyWith(color: AppColors.green700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Separate your recyclables from general waste to help reduce landfill impact.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.green700.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for stats since I updated PremiumCard slightly
class PremiumCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? bgColor;
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final Color? themeColor;

  const PremiumCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.bgColor,
    this.icon,
    this.title,
    this.subtitle,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.27, color: AppColors.grey100),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child ?? _buildDefaultContent(),
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor ?? AppColors.green700.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: themeColor ?? AppColors.green700, size: 16),
              ),
            if (icon != null) const SizedBox(width: 8),
            if (title != null) Text(title!, style: AppTypography.h2),
          ],
        ),
        if (subtitle != null) const SizedBox(height: 8),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTypography.caption.copyWith(color: AppColors.grey600),
          ),
      ],
    );
  }
}

