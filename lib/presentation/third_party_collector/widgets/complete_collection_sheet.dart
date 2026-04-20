import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class CompleteCollectionSheet extends StatefulWidget {
  final String title;
  final String address;
  final String person;

  const CompleteCollectionSheet({
    super.key,
    required this.title,
    required this.address,
    required this.person,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String address,
    required String person,
  }) {
    return Navigator.of(context).push<bool>(
      _CompleteCollectionRoute(
        child: CompleteCollectionSheet(
          title: title,
          address: address,
          person: person,
        ),
      ),
    );
  }

  @override
  State<CompleteCollectionSheet> createState() =>
      _CompleteCollectionSheetState();
}

class _CompleteCollectionSheetState extends State<CompleteCollectionSheet> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  @override
  void dispose() {
    _weight.dispose();
    _notes.dispose();
    _weightFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

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
              onTap: () {},
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, -6),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          height: 1,
                          color: AppColors.grey100,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                          child: _buildJobCard(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Collected Weight'),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _weight,
                                focusNode: _weightFocus,
                                hint: '0 kg',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Estimate the total weight collected',
                                style: AppTypography.captionSm,
                              ),
                              const SizedBox(height: 20),
                              _buildFieldLabel('Collection Notes'),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _notes,
                                focusNode: _notesFocus,
                                hint:
                                    'Add any observations, conditions, or special notes about the collection',
                                maxLines: 4,
                              ),
                              const SizedBox(height: 18),
                              _buildDisclaimer(),
                              const SizedBox(height: 20),
                              _buildCompleteButton(),
                            ],
                          ),
                        ),
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.emerald600,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald600.withValues(alpha: 0.25),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete Collection', style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(
                'Confirm the collection details before completing',
                style: AppTypography.bodySm,
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
    );
  }

  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emerald100, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.emerald100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.emerald700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTypography.titleMd),
                const SizedBox(height: 4),
                Text(
                  widget.address,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySm,
                    children: [
                      const TextSpan(text: 'Citizen: '),
                      TextSpan(
                        text: _shortName(widget.person),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.grey900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: '  (optional)',
            style: AppTypography.labelSm.copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? AppColors.emerald500 : AppColors.grey200,
              width: focused ? 1.4 : 1,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: AppColors.emerald500.withValues(alpha: 0.10),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            keyboardType: keyboardType,
            cursorColor: AppColors.emerald600,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200, width: 1),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.grey500,
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'By completing, you confirm the waste has been collected as agreed',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald600.withValues(alpha: 0.28),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: AppColors.emerald600,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(true),
            borderRadius: BorderRadius.circular(14),
            splashColor: AppColors.emerald700.withValues(alpha: 0.3),
            highlightColor: AppColors.emerald700.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.white20,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Complete Collection',
                    style: AppTypography.buttonLg.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteCollectionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _CompleteCollectionRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0x66000000),
        barrierLabel: 'Dismiss',
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final motion = CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.05, 0.7, 0.1, 1.0),
            reverseCurve: const Cubic(0.3, 0.0, 0.8, 0.15),
          );
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
            reverseCurve: const Interval(
              0.3,
              1.0,
              curve: Curves.easeInCubic,
            ),
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(motion),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.97,
                  end: 1.0,
                ).animate(motion),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
      );
}
