import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/auth/pages/forgot_password.dart';
import 'package:garbo_swms/presentation/auth/pages/role_selection.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  // Success transition
  bool _showSuccessOverlay = false;
  late final AnimationController _overlayController;
  late final Animation<double> _overlayFade;
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _overlayFade = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
  }

  // Load saved credentials from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  void _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // Debug: print the full response to console
        debugPrint('Login response: $body');

        final empId = body['empId'];
        final empName = body['empName'];

        if (empId == null) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed: no employee ID returned'),
              ),
            );
          }
          return;
        }

        // Save login data
        await prefs.setString('empId', empId.toString());
        await prefs.setString('empName', empName?.toString() ?? '');
        await prefs.setString('token', body['token'] ?? '');
        final role = body['role']?.toString() ?? '';
        await prefs.setString('role', role);

        debugPrint('Stored empId: ${prefs.getString('empId')}');

        // Save credentials if remember me is checked
        await _saveCredentials();

        // Bridge: sync AuthProvider state so collection team providers work
        if (mounted) {
          try {
            final authProvider = context.read<AuthProvider>();
            authProvider.setUserFromLoginResponse(body);
          } catch (e) {
            debugPrint('AuthProvider bridge skipped: $e');
          }
        }

        final nextRoute = AppRouter.routeForRole(role);
        if (mounted) {
          if (nextRoute == null) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This mobile app does not support the role "$role".',
                ),
              ),
            );
            return;
          }

          // Play success transition
          await _playSuccessTransition();

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              nextRoute,
              (route) => false,
            );
          }
        }
      } else {
        setState(() => _isLoading = false);
        final body = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['error'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      }
    }
  }

  Future<void> _playSuccessTransition() async {
    setState(() => _showSuccessOverlay = true);
    _overlayController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _overlayController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.emerald50,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        // Logo
                        Text(
                          'GARBO',
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLg.copyWith(
                            color: AppColors.green700,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Smart Waste Management',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.grey500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowSm,
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: AppTypography.h1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Happy to see you back to continue.',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.grey500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              // Username
                              Text('Username', style: AppTypography.titleSm),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your username',
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
                              const SizedBox(height: 20),
                              // Password
                              Text('Password', style: AppTypography.titleSm),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: AppTypography.bodyMd.copyWith(
                                    color: AppColors.grey400,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
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
                              const SizedBox(height: 12),
                              // Remember me and Forgot password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          activeColor: AppColors.green700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember me',
                                        style: AppTypography.bodySm.copyWith(
                                          color: AppColors.grey700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Forgotpassword(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.green700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green700,
                                    disabledBackgroundColor: AppColors.emerald500,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: AppTypography.buttonLg.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Create account
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RoleSelection(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Create Account',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.green700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 3),
                        // Terms and Privacy — anchored at bottom
                        Padding(
                          padding: EdgeInsets.only(bottom: bottomPadding + 16),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                'By signing up, you agree to our ',
                                style: AppTypography.captionSm.copyWith(
                                  color: AppColors.grey500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Terms of Service',
                                  style: AppTypography.captionSm.copyWith(
                                    color: AppColors.grey700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                ' and ',
                                style: AppTypography.captionSm.copyWith(
                                  color: AppColors.grey500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Privacy Policy',
                                  style: AppTypography.captionSm.copyWith(
                                    color: AppColors.grey700,
                                    decoration: TextDecoration.underline,
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
              ),
            );
          },
        ),
      ),
          // Success overlay
          if (_showSuccessOverlay)
            FadeTransition(
              opacity: _overlayFade,
              child: Container(
                color: AppColors.green700,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _checkScale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.green700,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _checkScale,
                        child: Text(
                          'Login Successful',
                          style: AppTypography.h2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
