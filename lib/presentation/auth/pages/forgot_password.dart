import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/auth_api.dart';
import 'package:http/http.dart' as http;

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _emailController = TextEditingController();
  final _authApi = AuthApi(
    client: http.Client(),
    authHeadersProvider: () async => {'Content-Type': 'application/json'},
    tokenProvider: () async => '',
  );
  bool _submitting = false;
  String? _feedback;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _feedback = 'Please enter your email');
      return;
    }
    setState(() {
      _submitting = true;
      _feedback = null;
    });
    try {
      await _authApi.requestPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _feedback =
            'If an account exists for that email, reset instructions have been sent.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _feedback = e.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

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
                const SizedBox(height: 20),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: AppDecorations.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: AppTypography.h1,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter your email and we\'ll send you a reset code.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Email',
                        style: AppTypography.titleSm,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: AppTypography.bodyMd.copyWith(
                            color: AppColors.grey400,
                          ),
                          prefixIcon: Icon(
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
                      if (_feedback != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _feedback!,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.green700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
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
                            _submitting ? 'Sending...' : 'Send Reset Instructions',
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
