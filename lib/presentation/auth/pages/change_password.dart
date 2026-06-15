import 'dart:convert';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:flutter/material.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/presentation/shared/widgets/submission_success.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: isError ? AppColors.red500 : AppColors.green700,
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('New passwords do not match', isError: true);
      return;
    }

    if (newPassword.length < 8) {
      _showSnackBar('Password must be at least 8 characters long', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';

      if (email.isEmpty) {
        _showSnackBar('Error: Email not found', isError: true);
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/auth/change-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        await showSubmissionSuccess(context, message: 'Password changed');

        final role = prefs.getString('role');
        final nextRoute = AppRouter.routeForRole(role) ?? AppRouter.login;
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, nextRoute, (route) => false);
      } else {
        final body = json.decode(response.body);
        if (mounted) {
          _showSnackBar(body['error'] ?? 'Failed to change password', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Connection error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey400),
      prefixIcon: Icon(prefixIcon, color: AppColors.grey400, size: 22),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green700, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.local_shipping, size: 60, color: AppColors.green700),
                    const SizedBox(height: 4),
                    Text(
                      'GARBO',
                      style: AppTypography.h2.copyWith(color: AppColors.green700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Change Password', style: AppTypography.h3),
                    const SizedBox(height: 8),
                    Text(
                      'Your account requires a password change on first login.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
                    ),
                    const SizedBox(height: 24),
                    Text('Current Password', style: AppTypography.titleSm),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: _fieldDecoration(
                        hint: 'Enter your current password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey400,
                          ),
                          onPressed: () => setState(
                            () => _obscureCurrentPassword = !_obscureCurrentPassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('New Password', style: AppTypography.titleSm),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: _fieldDecoration(
                        hint: 'Enter a new password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey400,
                          ),
                          onPressed: () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Password must be at least 8 characters long',
                      style: AppTypography.caption.copyWith(color: AppColors.grey600),
                    ),
                    const SizedBox(height: 20),
                    Text('Confirm New Password', style: AppTypography.titleSm),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: _fieldDecoration(
                        hint: 'Confirm your new password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey400,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green700,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.grey300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Change Password',
                                style: AppTypography.buttonLg.copyWith(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
