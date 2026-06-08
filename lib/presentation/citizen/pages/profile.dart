import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_achievement_list.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_expandable_section.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_logout_button.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_page_body.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_stats_section.dart';

class CitizenProfilePage extends StatefulWidget {
  const CitizenProfilePage({super.key});

  @override
  State<CitizenProfilePage> createState() => CitizenProfilePageState();
}

class CitizenProfilePageState extends State<CitizenProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const CitizenHeader(name: 'Profile'),
          Expanded(
            child: ProfilePageBody(
              profileCard: ProfileCard(
                name: 'Micheal',
                role: 'Citizen Account',
                employeeId: '-',
                email: 'michealmarsh@gmail.com',
                joinedDate: 'Jan 1, 2025',
              ),
              sections: [
                const ProfileStatsSection(
                  rows: [
                    ProfileStatRow(label: 'Reports Submitted', value: '9'),
                    ProfileStatRow(label: 'Events Joined', value: '2'),
                    ProfileStatRow(label: 'Reward Points', value: '145'),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ProfileAchievementList(),
                ),
                ProfileExpandableSection(
                  title: 'Contact Details',
                  icon: Icons.contact_page_outlined,
                  subtitle: 'Name, phone, email & address',
                  child: buildContactInfo(),
                ),
                ProfileExpandableSection(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  subtitle: 'Notifications, privacy & preferences',
                  child: buildSettingsOptions(),
                ),
              ],
              footer: const ProfileLogoutButton(
                dialogMessage:
                    "You'll need to sign in again to access your dashboard.",
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 4),
    );
  }

  Widget buildContactInfo() {
    return Column(
      children: [
        buildContactCard(
          icon: Icons.person_outline,
          label: 'Full Name',
          value: 'MIcheal Marsh',
        ),
        const SizedBox(height: 12),
        buildContactCard(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: '077 1234567',
        ),
        const SizedBox(height: 12),
        buildContactCard(
          icon: Icons.email_outlined,
          label: 'Email',
          value: 'michealmarsh@gmail.com',
        ),
        const SizedBox(height: 12),
        buildContactCard(
          icon: Icons.location_on_outlined,
          label: 'Default Address',
          value: '123 Main Street',
        ),
      ],
    );
  }

  Widget buildContactCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(icon, color: AppColors.green700, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsOptions() {
    return Column(
      children: [
        buildSettingItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your alerts',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications settings coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildSettingItem(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          subtitle: 'Password & data settings',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy & Security settings coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildSettingItem(
          icon: Icons.tune_outlined,
          title: 'Preferences',
          subtitle: 'App settings & defaults',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preferences settings coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildSettingItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs and contact us',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help & Support coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(icon, color: AppColors.green700, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.grey900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}
