import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class ThirdPartyEditProfilePage extends StatefulWidget {
  const ThirdPartyEditProfilePage({super.key});

  @override
  State<ThirdPartyEditProfilePage> createState() =>
      _ThirdPartyEditProfilePageState();
}

class _ThirdPartyEditProfilePageState extends State<ThirdPartyEditProfilePage> {
  final _nameController = TextEditingController(text: 'Sasindu Jayamadu');
  final _emailController = TextEditingController(text: 'demo@garbo.app');
  final _phoneController = TextEditingController(text: '71229939991');
  final _addressController = TextEditingController(
    text: '123 Main Street, City',
  );

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarCard(),
                  const SizedBox(height: 16),
                  _buildPersonalInfoCard(),
                  const SizedBox(height: 20),
                  _buildSaveButton(),
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
      decoration: const BoxDecoration(color: AppColors.emerald600),
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
                  'Edit Profile',
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Update your personal details',
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

  // ── Avatar Card ──────────────────────────────────────────────────────

  Widget _buildAvatarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.emerald600,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.emerald600,
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 3),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _onChangeAvatar,
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Sasindu Jayamadu',
            style: AppTypography.h3,
          ),
          const SizedBox(height: 2),
          Text(
            'Tap the camera icon to change photo',
            style: AppTypography.bodySm,
          ),
        ],
      ),
    );
  }

  // ── Personal Info Card ───────────────────────────────────────────────

  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.emerald600,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: AppTypography.titleLg,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your account details',
                        style: AppTypography.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              children: [
                _buildField(
                  label: 'Full Name',
                  hint: 'Your full name',
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Phone Number',
                  hint: '07X XXX XXXX',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Default Address',
                  hint: 'Street, city',
                  icon: Icons.location_on_outlined,
                  controller: _addressController,
                  focusNode: _addressFocus,
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Field ────────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, _) {
            final focused = focusNode.hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: focused ? Colors.white : AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused ? AppColors.emerald500 : AppColors.grey200,
                  width: focused ? 1.4 : 1,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: AppColors.emerald500.withValues(alpha: 0.10),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      icon,
                      size: 18,
                      color: focused
                          ? AppColors.emerald600
                          : AppColors.grey400,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      textCapitalization: textCapitalization,
                      cursorColor: AppColors.emerald600,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.grey900,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTypography.bodyMd.copyWith(
                          color: AppColors.grey400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Save Button ──────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Material(
      color: AppColors.emerald600,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _onSave,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.emerald700,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald600.withValues(alpha: 0.25),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Save Details',
                  style: AppTypography.buttonLg.copyWith(
                    color: Colors.white,
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

  // ── Actions ──────────────────────────────────────────────────────────

  void _onChangeAvatar() {
    FocusScope.of(context).unfocus();
  }

  void _onSave() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).maybePop();
  }
}
