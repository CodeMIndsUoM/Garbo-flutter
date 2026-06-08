import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Animated pulsing "HIGH PRIORITY" badge.
class HighPriorityBadge extends StatefulWidget {
  const HighPriorityBadge({super.key});

  @override
  State<HighPriorityBadge> createState() => _HighPriorityBadgeState();
}

class _HighPriorityBadgeState extends State<HighPriorityBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.red500.withValues(
              alpha: _opacityAnimation.value,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.red500.withValues(
                  alpha: _opacityAnimation.value * 0.4,
                ),
                blurRadius: 8 * _opacityAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            'HIGH PRIORITY',
            style: AppTypography.overline.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
