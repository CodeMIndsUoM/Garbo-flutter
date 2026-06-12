import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_edit_sheet.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_appearance_section.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_logout_button.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_page_body.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';

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
    syncAppColorsFromContext(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          CitizenHeader(name: 'Profile'),
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
                      showInfoChips: false,
                    ),
                    sections: [
                      buildProfileDetailsSection(),
                      const ProfileAppearanceSection(),
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

  Widget buildProfileDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.grey900, size: 20),
              const SizedBox(width: 8),
              Text('Profile Details', style: AppTypography.titleLg),
            ],
          ),
          const SizedBox(height: 12),
          CitizenSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _detailRow('Account Type', 'Citizen'),
                const _DetailDivider(),
                _detailRow('Council', 'Your local council'),
                const _DetailDivider(),
                _detailRow('Full Name', _name),
                const _DetailDivider(),
                _detailRow('Phone Number', _phone),
                const _DetailDivider(),
                _detailRow('Email', _email),
                const _DetailDivider(),
                _detailRow('Default Address', _address, alignTop: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool alignTop = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment:
            alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.titleMd.copyWith(
                color: AppColors.grey900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.titleMd.copyWith(
                color: AppColors.green700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppColors.grey100);
  }
}
