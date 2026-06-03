import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';

class ThirdPartyEditProfilePage extends StatefulWidget {
  const ThirdPartyEditProfilePage({super.key});

  @override
  State<ThirdPartyEditProfilePage> createState() =>
      _ThirdPartyEditProfilePageState();
}

class _ThirdPartyEditProfilePageState
    extends State<ThirdPartyEditProfilePage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _nicController = TextEditingController();
  final _companyController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _nicFocus = FocusNode();
  final _companyFocus = FocusNode();

  String _userId = '';
  String? _currentAvatarUrl;
  File? _pickedImageFile;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      _userId = await _apiService.getStoredEmpId();
      if (_userId.isNotEmpty) {
        final data = await _apiService.getThirdPartyCollectorProfile(_userId);
        if (data != null && mounted) {
          setState(() {
            _nameController.text = data['empName'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['defaultAddress'] ?? '';
            _nicController.text = data['nic'] ?? data['NIC'] ?? '';
            _companyController.text = data['company'] ?? '';
            _currentAvatarUrl = data['avatarUrl'] as String?;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nicController.dispose();
    _companyController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _nicFocus.dispose();
    _companyFocus.dispose();
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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.green700,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarCard(),
                        const SizedBox(height: 12),
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 24),
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
        MediaQuery.of(context).padding.top + 10,
        20,
        12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: AppColors.grey100,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.grey900,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: AppTypography.h2.copyWith(color: AppColors.grey900),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildAvatarImage(),
                ),
                // Camera badge
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Material(
                    color: AppColors.green700,
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.white, width: 3),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _uploadingPhoto ? null : _onChangeAvatar,
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: _uploadingPhoto
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
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
              _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'Your Name',
              style: AppTypography.titleLg.copyWith(color: AppColors.grey900, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the camera icon to change photo',
              style: AppTypography.bodySm.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    // If user picked a local file, show it
    if (_pickedImageFile != null) {
      return Image.file(
        _pickedImageFile!,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
      );
    }
    // If user has an existing cloud avatar, show it
    if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      return Image.network(
        _currentAvatarUrl!,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_rounded,
          color: AppColors.grey600,
          size: 48,
        ),
      );
    }
    // Default placeholder
    return const Icon(
      Icons.person_rounded,
      color: AppColors.grey600,
      size: 48,
    );
  }

  // ── Personal Info Card ───────────────────────────────────────────────

  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.green700,
                  size: 24,
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
                  readOnly: true,
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
                const SizedBox(height: 14),
                _buildField(
                  label: 'NIC',
                  hint: 'Your NIC number',
                  icon: Icons.badge_outlined,
                  controller: _nicController,
                  focusNode: _nicFocus,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Company Name',
                  hint: 'Company name (Optional)',
                  icon: Icons.business_outlined,
                  controller: _companyController,
                  focusNode: _companyFocus,
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
    bool readOnly = false,
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
                color: readOnly
                    ? AppColors.grey100
                    : (focused ? Colors.white : AppColors.grey50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused && !readOnly
                      ? AppColors.green700
                      : AppColors.grey200,
                  width: focused && !readOnly ? 1.4 : 1,
                ),
                boxShadow: focused && !readOnly
                    ? [
                        BoxShadow(
                          color: AppColors.green700.withValues(alpha: 0.10),
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
                      color: focused && !readOnly
                          ? AppColors.green700
                          : AppColors.grey400,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      textCapitalization: textCapitalization,
                      readOnly: readOnly,
                      cursorColor: AppColors.green700,
                      style: AppTypography.bodyMd.copyWith(
                        color: readOnly ? AppColors.grey600 : AppColors.grey900,
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
                  if (readOnly)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: AppColors.grey400,
                      ),
                    )
                  else
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
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _saving ? null : _onSave,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_saving)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              _saving ? 'Saving...' : 'Save Details',
              style: AppTypography.buttonLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────

  Future<void> _onChangeAvatar() async {
    FocusScope.of(context).unfocus();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    setState(() {
      _pickedImageFile = file;
      _uploadingPhoto = true;
    });

    try {
      final url = await _apiService.uploadProfilePicture(_userId, file);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _pickedImageFile = null;
          _uploadingPhoto = false;
        });
        _showSnack('Photo upload failed. Please try again.', success: false);
        return;
      }
      setState(() {
        _currentAvatarUrl = url;
        _pickedImageFile = null;
        _uploadingPhoto = false;
      });
      _showSnack('Profile photo uploaded to Cloudinary.', success: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pickedImageFile = null;
        _uploadingPhoto = false;
      });
      _showSnack('Failed to upload photo. Please try again.', success: false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Text('Change Profile Photo',
                  style: AppTypography.titleLg),
              const SizedBox(height: 16),
              _sourceOption(
                ctx: ctx,
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                source: ImageSource.camera,
              ),
              const SizedBox(height: 8),
              _sourceOption(
                ctx: ctx,
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                source: ImageSource.gallery,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return Material(
      color: AppColors.grey50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(ctx).pop(source),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.green700, size: 22),
              const SizedBox(width: 14),
              Text(label,
                  style: AppTypography.titleMd
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Full name cannot be empty', success: false);
      return;
    }
    setState(() => _saving = true);

    try {
      final success = await _apiService.updateThirdPartyCollectorProfile(_userId, {
        'empName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'defaultAddress': _addressController.text.trim(),
        'NIC': _nicController.text.trim(),
        'company': _companyController.text.trim(),
      });

      if (!mounted) return;

      if (success) {
        _showSnack('Profile updated successfully!', success: true);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).maybePop();
      } else {
        _showSnack('Failed to save profile. Please try again.', success: false);
      }
    } catch (_) {
      if (mounted) {
        _showSnack('An error occurred. Please check your connection.',
            success: false);
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _showSnack(String message, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            success ? AppColors.green700 : AppColors.red500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
