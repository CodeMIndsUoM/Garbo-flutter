import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_achievement_list.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_edit_sheet.dart';
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
  final ApiService _apiService = ApiService();

  String _name = 'Citizen';
  String _employeeId = '-';
  String _email = '-';
  String _phone = '-';
  String _address = '-';
  String _joinedDate = '-';
  String? _avatarUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final empId = await _apiService.getStoredEmpId();
      if (empId.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final profile = await _apiService.getUserProfile(empId);
      if (!mounted || profile == null) {
        setState(() => _loading = false);
        return;
      }

      setState(() {
        _employeeId = empId;
        _name = (profile['empName'] ?? 'Citizen').toString();
        _email = (profile['email'] ?? '-').toString();
        _phone = (profile['phone'] ?? '-').toString();
        _address = (profile['defaultAddress'] ?? '-').toString();
        final avatar = (profile['avatarUrl'] ?? '').toString();
        _avatarUrl = avatar.isEmpty ? null : avatar;
        _joinedDate = _formatJoinedDate(profile['createdAt']);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatJoinedDate(dynamic rawCreatedAt) {
    if (rawCreatedAt == null) return '-';
    try {
      final parsed = DateTime.parse(rawCreatedAt.toString());
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return '-';
    }
  }

  void _openEditSheet() {
    showUserProfileEditSheet(
      context: context,
      apiService: _apiService,
      userId: _employeeId,
      avatarUrl: _avatarUrl,
      initial: ProfileEditFields(
        name: _name,
        phone: _phone == '-' ? '' : _phone,
        defaultAddress: _address == '-' ? '' : _address,
      ),
      onUpdated: _loadProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          CitizenHeader(name: _loading ? 'Profile' : _name),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ProfilePageBody(
                    profileCard: ProfileCard(
                      name: _name,
                      role: 'Citizen Account',
                      employeeId: _employeeId,
                      email: _email,
                      joinedDate: _joinedDate,
                      avatarUrl: _avatarUrl,
                      onEditTap: _openEditSheet,
                    ),
                    sections: [
                      const ProfileStatsSection(
                        rows: [
                          ProfileStatRow(label: 'Account Type', value: 'Citizen'),
                          ProfileStatRow(label: 'Council', value: 'Your local council'),
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
          value: _name,
        ),
        const SizedBox(height: 12),
        buildContactCard(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: _phone,
        ),
        const SizedBox(height: 12),
        buildContactCard(
          icon: Icons.email_outlined,
          label: 'Email',
          value: _email,
        ),
        const SizedBox(height: 12),
        buildContactCard(
          icon: Icons.location_on_outlined,
          label: 'Default Address',
          value: _address,
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
