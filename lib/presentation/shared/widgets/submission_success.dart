import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

/// Shows a smooth animated success popup with a green check circle.
Future<void> showSubmissionSuccess(
  BuildContext context, {
  String message = 'Done!',
  Duration holdDuration = const Duration(milliseconds: 1400),
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Success',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return _SubmissionSuccessOverlay(
        animation: animation,
        holdDuration: holdDuration,
      );
    },
  );
}

class _SubmissionSuccessOverlay extends StatefulWidget {
  const _SubmissionSuccessOverlay({
    required this.animation,
    required this.holdDuration,
  });

  final Animation<double> animation;
  final Duration holdDuration;

  @override
  State<_SubmissionSuccessOverlay> createState() =>
      _SubmissionSuccessOverlayState();
}

class _SubmissionSuccessOverlayState extends State<_SubmissionSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    widget.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkController.forward();
      }
    });

    Future<void>.delayed(widget.holdDuration, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: fade,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(fade),
            child: ScaleTransition(
              scale: _checkScale,
              child: const SubmissionSuccessBadge(size: 88, iconSize: 48),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green circle with white check — reusable in dialogs and full-screen overlays.
class SubmissionSuccessBadge extends StatelessWidget {
  const SubmissionSuccessBadge({
    super.key,
    this.size = 80,
    this.iconSize = 44,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green700,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.green700.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}
