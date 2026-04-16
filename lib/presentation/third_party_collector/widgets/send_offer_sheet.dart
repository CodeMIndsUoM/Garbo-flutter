import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class SendOfferSheet extends StatefulWidget {
  final String wasteType;
  final String location;
  final String preferredTime;

  const SendOfferSheet({
    super.key,
    required this.wasteType,
    required this.location,
    required this.preferredTime,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String wasteType,
    required String location,
    required String preferredTime,
  }) {
    return Navigator.of(context).push<bool>(
      _SendOfferRoute(
        child: SendOfferSheet(
          wasteType: wasteType,
          location: location,
          preferredTime: preferredTime,
        ),
      ),
    );
  }

  @override
  State<SendOfferSheet> createState() => _SendOfferSheetState();
}

class _SendOfferSheetState extends State<SendOfferSheet> {
  String? _offerType;
  final TextEditingController _notes = TextEditingController();
  final FocusNode _notesFocus = FocusNode();

  static const List<String> _offerTypes = [
    'Free Pickup',
    'Pay by Weight',
    'Fixed Price',
    'Exchange / Barter',
  ];

  @override
  void dispose() {
    _notes.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.92;

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
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        Container(height: 1, color: AppColors.grey100),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('Request Summary'),
                                const SizedBox(height: 10),
                                _buildSummaryCard(),
                                const SizedBox(height: 20),
                                _buildFieldLabel('Offer Description'),
                                const SizedBox(height: 10),
                                _buildDropdown(),
                                const SizedBox(height: 8),
                                Text(
                                  "Be clear and specific about what you're offering",
                                  style: AppTypography.captionSm,
                                ),
                                const SizedBox(height: 20),
                                _buildFieldLabel(
                                  'Additional Notes',
                                  optional: true,
                                ),
                                const SizedBox(height: 10),
                                _buildNotesField(),
                                const SizedBox(height: 18),
                                _buildInfoBanner(),
                                const SizedBox(height: 20),
                                _buildSendButton(),
                              ],
                            ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send Collection Offer', style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(
                'Propose how you can collect or exchange this waste item',
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTypography.titleSm.copyWith(color: AppColors.grey900),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emerald100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Waste Type', widget.wasteType),
          const SizedBox(height: 10),
          _buildSummaryRow('Location', widget.location),
          const SizedBox(height: 10),
          _buildSummaryRow('Preferred Time', widget.preferredTime),
          const SizedBox(height: 14),
          _buildViewLocationButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emerald500, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.near_me_rounded,
                  color: AppColors.emerald600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'View Location',
                  style: AppTypography.buttonMd.copyWith(
                    color: AppColors.emerald700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool optional = false}) {
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
          if (optional)
            TextSpan(
              text: '  (optional)',
              style: AppTypography.labelSm.copyWith(color: AppColors.grey400),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _offerType,
          hint: Text(
            'Describe Your Offer',
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey400),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey500,
          ),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
          items: _offerTypes
              .map(
                (v) => DropdownMenuItem<String>(
                  value: v,
                  child: Text(
                    v,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _offerType = v),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return AnimatedBuilder(
      animation: _notesFocus,
      builder: (context, _) {
        final focused = _notesFocus.hasFocus;
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
            controller: _notes,
            focusNode: _notesFocus,
            maxLines: 3,
            cursorColor: AppColors.emerald600,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: 'Add any additional information or special conditions',
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald100, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.emerald100,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.emerald700,
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Offers are reviewed by citizens before confirmation',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.emerald800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final enabled = _offerType != null;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.emerald600.withValues(alpha: 0.28),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: enabled ? AppColors.emerald600 : AppColors.grey300,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled
                ? () => Navigator.of(context).pop(true)
                : null,
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
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Send Offer',
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

class _SendOfferRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _SendOfferRoute({required this.child})
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
