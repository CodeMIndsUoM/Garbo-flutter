import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditFields {
  final String name;
  final String? phone;
  final String? defaultAddress;

  const ProfileEditFields({
    required this.name,
    this.phone,
    this.defaultAddress,
  });
}

Future<void> showUserProfileEditSheet({
  required BuildContext context,
  required ApiService apiService,
  required String userId,
  required ProfileEditFields initial,
  String? avatarUrl,
  required VoidCallback onUpdated,
}) async {
  final nameController = TextEditingController(text: initial.name);
  final phoneController = TextEditingController(text: initial.phone ?? '');
  final addressController =
      TextEditingController(text: initial.defaultAddress ?? '');
  final picker = ImagePicker();
  var uploadingPhoto = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> changePhoto() async {
            final source = await showModalBottomSheet<ImageSource>(
              context: context,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt_rounded),
                      title: const Text('Take a Photo'),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_rounded),
                      title: const Text('Choose from Gallery'),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            );
            if (source == null) return;

            final picked = await picker.pickImage(
              source: source,
              maxWidth: 800,
              maxHeight: 800,
              imageQuality: 85,
            );
            if (picked == null) return;

            setSheetState(() => uploadingPhoto = true);
            final url = await apiService.uploadProfilePicture(
              userId,
              File(picked.path),
            );
            setSheetState(() => uploadingPhoto = false);
            if (url != null && url.isNotEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo updated')),
                );
              }
              onUpdated();
            }
          }

          Future<void> removePhoto() async {
            setSheetState(() => uploadingPhoto = true);
            final ok = await apiService.removeProfilePicture(userId);
            setSheetState(() => uploadingPhoto = false);
            if (ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo removed')),
              );
              onUpdated();
            }
          }

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
                Text('Edit Profile', style: AppTypography.h3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: uploadingPhoto ? null : changePhoto,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Change Photo'),
                    ),
                    if (avatarUrl != null && avatarUrl.isNotEmpty)
                      TextButton.icon(
                        onPressed: uploadingPhoto ? null : removePhoto,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Remove Photo'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Default Address'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final payload = <String, dynamic>{
                        'empName': nameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'defaultAddress': addressController.text.trim(),
                      };
                      final ok = await apiService.updateUserProfile(
                        userId,
                        payload,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (ok) {
                          onUpdated();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated'),
                              backgroundColor: AppColors.green700,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Save Changes',
                      style: AppTypography.buttonLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
