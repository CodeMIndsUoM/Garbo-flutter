import 'dart:convert';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/auth/pages/forgot_password.dart';
import 'package:garbo_swms/presentation/auth/pages/register.dart';
import 'package:garbo_swms/presentation/auth/pages/collector_register.dart';
import 'package:garbo_swms/presentation/auth/widgets/auth_hero_background.dart';
import 'package:garbo_swms/presentation/shared/widgets/submission_success.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key, this.enterAnimation});

  /// When set, the login sheet motion is driven by the route transition
  /// (splash → login handoff).
  final Animation<double>? enterAnimation;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  int _selectedTab = 0; // 0 for Login, 1 for Register
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Success transition
  bool _showSuccessOverlay = false;
  late final AnimationController _overlayController;
  late final Animation<double> _overlayFade;
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  AnimationController? _sheetController;
  late final Animation<Offset> _sheetSlide;
  late final Animation<double> _sheetFade;
  late final Animation<double> _headerFade;

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

    final enterAnimation = widget.enterAnimation;
    if (enterAnimation != null) {
      final sheetMotion = CurvedAnimation(
        parent: enterAnimation,
        curve: const Interval(0.06, 1.0, curve: Curves.easeOutCubic),
      );
      _sheetSlide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(sheetMotion);
      _sheetFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: enterAnimation,
          curve: const Interval(0.06, 0.88, curve: Curves.easeOut),
        ),
      );
      _headerFade = Tween<double>(begin: 0.9, end: 1).animate(
        CurvedAnimation(
          parent: enterAnimation,
          curve: const Interval(0, 0.5, curve: Curves.easeOut),
        ),
      );
    } else {
      _sheetController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 720),
      );
      _sheetSlide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _sheetController!,
          curve: Curves.easeOutCubic,
        ),
      );
      _sheetFade = CurvedAnimation(
        parent: _sheetController!,
        curve: const Interval(0, 0.75, curve: Curves.easeOut),
      );
      _headerFade = const AlwaysStoppedAnimation(1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sheetController?.forward();
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _overlayController.dispose();
    _checkController.dispose();
    _sheetController?.dispose();
    super.dispose();
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
    final email = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
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
        await prefs.setString('email', email);
        await prefs.setString('token', body['token'] ?? '');
        final role = body['role']?.toString() ?? '';
        await prefs.setString('role', role);
        final council = body['council']?.toString();
        if (council != null && council.isNotEmpty) {
          await prefs.setString('council', council);
        }
        final mustChangePassword = body['mustChangePassword'] ?? false;

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

        // If password change is required, redirect to change password
        if (mustChangePassword) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/change-password',
              (route) => false,
            );
          }
          return;
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

  Widget _buildRegisterCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
          boxShadow: AppDecorations.cardShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 28, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleLg.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Material(
      elevation: 4,
      shadowColor: AppColors.green700.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green700,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.green700.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Log in',
                  style: AppTypography.buttonLg.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }

  InputDecoration _loginFieldDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    final fieldBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(28)),
      borderSide: BorderSide(color: AppColors.textPrimary, width: 1),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyMd.copyWith(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: AppTypography.labelMd.copyWith(
        color: AppColors.textPrimary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: AppColors.textPrimary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildTabLabel(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.titleSm.copyWith(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: AppTransitions.tab,
              curve: AppTransitions.enter,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? AppColors.green700 : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final headerHeight = MediaQuery.of(context).size.height * 0.34;

    return Scaffold(
      backgroundColor: AppColors.emerald900,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AuthHeroBackground(
              imageAlignment: Alignment(0, -0.45),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: headerHeight,
                width: double.infinity,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GARBO',
                            style: AppTypography.displayLg.copyWith(
                              color: Colors.white,
                              letterSpacing: 6,
                              shadows: const [
                                Shadow(
                                  color: Color(0x59000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Smart Waste Management',
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              letterSpacing: 1,
                              shadows: const [
                                Shadow(
                                  color: Color(0x4D000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: headerHeight - 28,
            bottom: 0,
            child: SlideTransition(
              position: _sheetSlide,
              child: FadeTransition(
                opacity: _sheetFade,
                child: _buildFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _buildTabLabel(
                            'Log in',
                            _selectedTab == 0,
                            () => setState(() => _selectedTab = 0),
                          ),
                          _buildTabLabel(
                            'Register',
                            _selectedTab == 1,
                            () => setState(() => _selectedTab = 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      AnimatedSwitcher(
                        duration: AppTransitions.tab,
                        switchInCurve: AppTransitions.enter,
                        switchOutCurve: AppTransitions.exit,
                        transitionBuilder: (child, animation) {
                          final isLogin = (child.key as ValueKey<String>?)?.value ==
                              'login_form_view';
                          return AppTransitions.buildTabSwitch(
                            animation: animation,
                            child: child,
                            slideFromLeft: isLogin,
                          );
                        },
                        child: _selectedTab == 0
                            ? Column(
                            key: const ValueKey('login_form_view'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _usernameController,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: _loginFieldDecoration(label: 'Email'),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: _loginFieldDecoration(
                                  label: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              RichText(
                                text: TextSpan(
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Forget password? '),
                                    TextSpan(
                                      text: 'Reset it',
                                      style: AppTypography.titleSm.copyWith(
                                        color: AppColors.green700,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.pushAppPage(
                                            const Forgotpassword(),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildLoginButton(),
                              const SizedBox(height: 24),
                            ],
                          )
                        : Column(
                            key: const ValueKey('register_choices_view'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Select your role to start registration',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildRegisterCard(
                                icon: Icons.person_outline,
                                title: 'Citizen',
                                description:
                                    'Report waste items and request waste pickups in your area.',
                                onTap: () {
                                  context.pushAppPage(const Register());
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildRegisterCard(
                                icon: Icons.local_shipping_outlined,
                                title: 'Third Party Collector',
                                description:
                                    'Offer waste collection services for citizens and local authorities.',
                                onTap: () {
                                  context.pushAppPage(
                                    const CollectorRegister(),
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
              ),
            ),
          ),
          
          // Success Overlay Animation
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
                        child: const SubmissionSuccessBadge(size: 80, iconSize: 44),
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
