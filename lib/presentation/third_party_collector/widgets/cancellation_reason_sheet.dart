import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class CancellationReasonSheet extends StatelessWidget {
  const CancellationReasonSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return Navigator.of(
      context,
    ).push<String>(_ReasonSheetRoute(child: const CancellationReasonSheet()));
  }

  IconData _getReasonIcon(String reason) {
    return switch (reason) {
      'VEHICLE_BREAKDOWN' => Icons.construction_rounded,
      'WRONG_ADDRESS' => Icons.wrong_location_rounded,
      'CITIZEN_UNREACHABLE' => Icons.phone_disabled_rounded,
      'ROUTE_CHANGED' => Icons.alt_route_rounded,
      _ => Icons.help_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    const reasons = [
      'VEHICLE_BREAKDOWN',
      'WRONG_ADDRESS',
      'CITIZEN_UNREACHABLE',
      'ROUTE_CHANGED',
      'OTHER',
    ];

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside sheet from dismissing it
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowMd,
                      offset: Offset(0, -6),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.grey300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald50,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.green700,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cancel Collection Offer',
                                    style: AppTypography.h3.copyWith(
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Select the reason for cancelling this offer',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.grey600,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(height: 1, color: AppColors.grey100),
                        const SizedBox(height: 16),

                        // Reason Cards List
                        ...reasons.map((reason) {
                          final icon = _getReasonIcon(reason);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: AppColors.grey50,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(reason),
                                borderRadius: BorderRadius.circular(16),
                                splashColor: AppColors.green700.withValues(
                                  alpha: 0.08,
                                ),
                                highlightColor: AppColors.green700.withValues(
                                  alpha: 0.04,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.grey200,
                                      width: 1.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadowSm,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: AppColors.emerald50,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          icon,
                                          color: AppColors.green700,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          reason.replaceAll('_', ' '),
                                          style: AppTypography.titleMd.copyWith(
                                            color: AppColors.grey900,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.grey400,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonSheetRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _ReasonSheetRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.scrim,
        barrierLabel: 'Dismiss',
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 850),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeOutCubic,
                ),
              );

          final scrimFade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeOut,
          );

          return Stack(
            children: [
              FadeTransition(
                opacity: scrimFade,
                child: const SizedBox.expand(),
              ),
              SlideTransition(position: slide, child: child),
            ],
          );
        },
      );
}
