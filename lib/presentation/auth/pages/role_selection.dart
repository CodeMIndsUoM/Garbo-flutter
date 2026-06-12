import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/auth/pages/collector_register.dart';
import 'package:garbo_swms/presentation/auth/pages/register.dart';

/// Role Selection Screen
/// Allows users to choose between Citizen and Third Party Collector registration
class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Your Role', style: AppTypography.titleLg),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: AppColors.green700,
                ),
                const SizedBox(height: 24),
                Text(
                  'Who are you?',
                  style: AppTypography.titleLg,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select your role to continue with registration',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Citizen Card
                _buildRoleCard(
                  context,
                  icon: Icons.person,
                  title: 'Citizen',
                  description:
                      'Register as a citizen to report waste and request collections',
                  onTap: () {
                    context.pushAppPage(const Register());
                  },
                ),
                const SizedBox(height: 24),
                // Third Party Collector Card
                _buildRoleCard(
                  context,
                  icon: Icons.local_shipping,
                  title: 'Third Party Collector',
                  description: 'Register as a third-party waste collector',
                  onTap: () {
                    context.pushAppPage(const CollectorRegister());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSm,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.green700),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMd),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}
