import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_achievement_list.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_logout_button.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_page_body.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  String _name = 'Field Staff';
  String _role = 'Field Staff';
  String _employeeId = '-';
  String _email = '-';
  String _joinedDate = '-';
  String? _avatarUrl;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final empId = await _apiService.getStoredEmpId();
      final empName = await _apiService.getStoredEmpName();

      if (!mounted) return;

      setState(() {
        if (empName.trim().isNotEmpty) {
          _name = empName;
        }
        _employeeId = empId.trim().isNotEmpty ? empId : '-';
      });

      if (empId.trim().isEmpty) {
        return;
      }

      final profile = await _apiService.getUserProfile(empId);
      if (!mounted || profile == null) return;

      setState(() {
        final dbName = (profile['empName'] ?? '').toString().trim();
        final dbEmail = (profile['email'] ?? '').toString().trim();
        final dbRole = (profile['role'] ?? '').toString().trim();
        final dbAvatar = (profile['avatarUrl'] ?? '').toString().trim();

        if (dbName.isNotEmpty) _name = dbName;
        if (dbEmail.isNotEmpty) _email = dbEmail;
        if (dbAvatar.isNotEmpty) _avatarUrl = dbAvatar;
        if (dbRole.isNotEmpty) {
          _role = dbRole
              .toLowerCase()
              .replaceAll('_', ' ')
              .split(' ')
              .where((part) => part.isNotEmpty)
              .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
              .join(' ');
        }

        _joinedDate = _formatJoinedDate(profile['createdAt']);
      });
    } catch (_) {
      // Keep fallbacks when profile loading fails.
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

  Future<void> _onChangeAvatar() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
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
              Text('Change Profile Photo', style: AppTypography.titleLg),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.green700),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.green700),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

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
      _uploadingPhoto = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Uploading photo...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final url = await _apiService.uploadProfilePicture(_employeeId, file);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _uploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo upload failed. Please try again.'),
            backgroundColor: AppColors.red500,
          ),
        );
        return;
      }
      setState(() {
        _avatarUrl = url;
        _uploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
          backgroundColor: AppColors.green700,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload photo.'),
          backgroundColor: AppColors.red500,
        ),
      );
    }
  }

  void _openEditProfileSheet() {
    final nameController = TextEditingController(text: _name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: AppTypography.h3.copyWith(color: AppColors.grey900),
                  ),
                  TextButton.icon(
                    onPressed: _uploadingPhoto ? null : () {
                      Navigator.of(context).pop();
                      _onChangeAvatar();
                    },
                    icon: const Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.green700),
                    label: Text(
                      'Change Photo',
                      style: AppTypography.labelMd.copyWith(color: AppColors.green700, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    TextButton.icon(
                      onPressed: _uploadingPhoto ? null : () async {
                        Navigator.of(context).pop();
                        setState(() => _uploadingPhoto = true);
                        final ok = await _apiService.removeProfilePicture(_employeeId);
                        if (!mounted) return;
                        setState(() {
                          _uploadingPhoto = false;
                          if (ok) _avatarUrl = null;
                        });
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo removed')),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red500),
                      label: Text(
                        'Remove Photo',
                        style: AppTypography.labelMd.copyWith(color: AppColors.red500, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Full Name',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.grey700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                cursorColor: AppColors.green700,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: AppColors.grey50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.green700, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    if (newName.isEmpty) return;

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Updating profile...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    try {
                      final success = await _apiService.updateUserProfile(
                        _employeeId,
                        {'empName': newName},
                      );
                      if (!context.mounted) return;
                      if (success) {
                        setState(() {
                          _name = newName;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppColors.green700,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update profile.'),
                            backgroundColor: AppColors.red500,
                          ),
                        );
                      }
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error updating profile.'),
                          backgroundColor: AppColors.red500,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Save Details',
                    style: AppTypography.buttonLg.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageBody(
      profileCard: ProfileCard(
        name: _name,
        role: _role,
        employeeId: _employeeId,
        email: _email,
        joinedDate: _joinedDate,
        avatarUrl: _avatarUrl,
        onEditTap: _openEditProfileSheet,
      ),
      sections: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ProfilePerformanceGrid(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ProfileAchievementList(),
        ),
      ],
      footer: const ProfileLogoutButton(),
    );
  }
}
