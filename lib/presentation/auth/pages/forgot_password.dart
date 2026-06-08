import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class Forgotpassword extends StatelessWidget {
  const Forgotpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo
                Center(
                  child: Text(
                    'GARBO',
                    style: AppTypography.displayLg.copyWith(
                      color: AppColors.green700,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Smart Waste Management',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Back to Login
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: AppColors.green700),
                  label: Text(
                    'Back to Login',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.green700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 20),
                // Card with forgot password form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Forgot Password title
                      Text(
                        'Forgot Password?',
                        style: AppTypography.h1,
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Text(
                        'No worries! Enter your username or email and we\'ll send you reset instructions.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Username or Email field
                      Text(
                        'Username or Email',
                        style: AppTypography.titleSm,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your username or email',
                          hintStyle: AppTypography.bodyMd.copyWith(
                            color: AppColors.grey400,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.grey400,
                            size: 22,
                          ),
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
                            borderSide: const BorderSide(
                              color: AppColors.green700,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.grey50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Send Reset Instructions button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Send Reset Instructions',
                            style: AppTypography.buttonLg.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Help text
                Center(
                  child: Text(
                    'Need help? Contact your system administrator',
                    style: AppTypography.captionSm.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
