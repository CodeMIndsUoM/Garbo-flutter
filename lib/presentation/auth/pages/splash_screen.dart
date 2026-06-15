import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/core/router/auth_routes.dart';
import 'package:garbo_swms/presentation/auth/widgets/auth_hero_background.dart';
import 'package:garbo_swms/presentation/shared/widgets/garbo_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 2200);
  static const _holdBeforeExit = Duration(milliseconds: 220);

  late final AnimationController _introController;
  late final AnimationController _exitController;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroOpacity;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _lineOpacity;
  late final Animation<double> _lineWidth;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _loaderOpacity;
  late final Animation<double> _exitFade;
  late final Animation<Offset> _exitLogoShift;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: _introDuration,
    );

    const logoCurve = Curves.easeOutCubic;
    const detailCurve = Curves.easeInOutCubic;

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.42, curve: logoCurve),
      ),
    );

    _logoScale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.48, curve: logoCurve),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.48, curve: logoCurve),
      ),
    );

    _lineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.32, 0.52, curve: detailCurve),
      ),
    );

    _lineWidth = Tween<double>(begin: 0, end: 60).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.32, 0.56, curve: detailCurve),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.48, 0.72, curve: detailCurve),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.48, 0.72, curve: detailCurve),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.62, 0.88, curve: Curves.easeOut),
      ),
    );

    _heroScale = Tween<double>(begin: 1.08, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 1, curve: Curves.easeOutCubic),
      ),
    );

    _heroOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.45, curve: Curves.easeOut),
      ),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _exitFade = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOutCubic,
    );
    _exitLogoShift = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.22),
    ).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _startIntro();
  }

  Future<void> _startIntro() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    await _introController.forward();
    if (!mounted) return;

    await Future<void>.delayed(_holdBeforeExit);
    if (!mounted) return;

    await _exitController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(AuthRoutes.splashToLogin());
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  double _fadeOut(double value) => value * (1 - _exitFade.value);

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_introController, _exitController]),
        builder: (context, child) {
          final logoShift = Offset.lerp(
            _logoSlide.value,
            _logoSlide.value + _exitLogoShift.value,
            _exitFade.value,
          )!;

          return Stack(
            fit: StackFit.expand,
            children: [
              AuthHeroBackground(
                imageOpacity: _heroOpacity.value,
                imageScale: _heroScale.value,
              ),
              Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: SlideTransition(
                          position: AlwaysStoppedAnimation(logoShift),
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: const GarboLogo(height: 132),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: _fadeOut(_lineOpacity.value),
                        child: Container(
                          width: _lineWidth.value,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.emerald200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: SlideTransition(
                          position: _taglineSlide,
                          child: Opacity(
                            opacity: 1 - _exitFade.value,
                            child: Text(
                              'Smart Waste Management',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.white70,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _fadeOut(_loaderOpacity.value),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
