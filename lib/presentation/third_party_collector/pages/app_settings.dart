import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class ThirdPartyAppSettingsPage extends StatefulWidget {
  const ThirdPartyAppSettingsPage({super.key});

  @override
  State<ThirdPartyAppSettingsPage> createState() =>
      _ThirdPartyAppSettingsPageState();
}

class _ThirdPartyAppSettingsPageState extends State<ThirdPartyAppSettingsPage> {
  bool _darkMode = false;
  final String _language = 'English';
  final String _cacheSize = '45.2 MB';
  final String _appVersion = '2.4.1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Appearance',
                    subtitle: 'Theme and language preferences',
                    children: [
                      _buildSwitchRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        description: 'Enable dark theme',
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                      ),
                      const _RowDivider(),
                      _buildNavRow(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        description: _language,
                        onTap: _openLanguagePicker,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildSection(
                    title: 'Privacy & Security',
                    subtitle: 'Control your data and privacy',
                    children: [
                      _buildNavRow(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Policy',
                        description: 'View our privacy policy',
                        onTap: () {},
                      ),
                      const _RowDivider(),
                      _buildNavRow(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        description: 'Read our terms',
                        onTap: () {},
                      ),
                      const _RowDivider(),
                      _buildNavRow(
                        icon: Icons.folder_shared_outlined,
                        label: 'Data Management',
                        description: 'Manage your data',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildSection(
                    title: 'Support',
                    subtitle: 'Help and feedback',
                    children: [
                      _buildNavRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        description: 'Get help and support',
                        onTap: () {},
                      ),
                      const _RowDivider(),
                      _buildNavRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Contact Us',
                        description: 'Send us a message',
                        onTap: () {},
                      ),
                      const _RowDivider(),
                      _buildNavRow(
                        icon: Icons.feedback_outlined,
                        label: 'Send Feedback',
                        description: 'Help us improve',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildSection(
                    title: 'About',
                    subtitle: 'App information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.info_outline_rounded,
                        label: 'App Version',
                        description: _appVersion,
                      ),
                      const _RowDivider(),
                      _buildNavRow(
                        icon: Icons.campaign_outlined,
                        label: "What's New",
                        description: 'See latest updates',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildStorageSection(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 14,
        20,
        18,
      ),
      decoration: const BoxDecoration(color: AppColors.green700),
      child: Row(
        children: [
          Material(
            color: AppColors.white20,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize your app experience',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.white80,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section ──────────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodySm),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // ── Row variants ─────────────────────────────────────────────────────

  Widget _buildNavRow({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: _rowContent(
          icon: icon,
          label: label,
          description: description,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.grey400,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _rowContent(
      icon: icon,
      label: label,
      description: description,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.green700,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: AppColors.grey300,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return _rowContent(
      icon: icon,
      label: label,
      description: description,
    );
  }

  Widget _rowContent({
    required IconData icon,
    required String label,
    required String description,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Text(
                  label,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(description, style: AppTypography.bodySm),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  // ── Storage Section ──────────────────────────────────────────────────

  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Storage', style: AppTypography.h3),
              const SizedBox(height: 2),
              Text('Free up space used by the app', style: AppTypography.bodySm),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.emerald50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storage_rounded,
                      color: AppColors.green700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cache Size',
                          style: AppTypography.titleMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Temporary files used for faster loading',
                          style: AppTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _cacheSize,
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.green800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildClearCacheButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClearCacheButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _onClearCache,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.red100, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.red500,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Clear Cache',
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

  // ── Actions ──────────────────────────────────────────────────────────

  void _openLanguagePicker() {}

  void _onClearCache() {}
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
