import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

enum OfferStatus { pending, accepted, rejected }

class OfferDetailsSheet extends StatelessWidget {
  final String title;
  final String person;
  final String location;
  final String distance;
  final String postedAgo;
  final OfferStatus status;
  final String? pickup;
  final String? contact;
  final String? address;

  const OfferDetailsSheet({
    super.key,
    required this.title,
    required this.person,
    required this.location,
    required this.distance,
    required this.postedAgo,
    required this.status,
    this.pickup,
    this.contact,
    this.address,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String person,
    required String location,
    required String distance,
    required String postedAgo,
    required OfferStatus status,
    String? pickup,
    String? contact,
    String? address,
  }) {
    return Navigator.of(context).push<bool>(
      _SheetRoute(
        child: OfferDetailsSheet(
          title: title,
          person: person,
          location: location,
          distance: distance,
          postedAgo: postedAgo,
          status: status,
          pickup: pickup,
          contact: contact,
          address: address,
        ),
      ),
    );
  }

  String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }

  (IconData icon, Color color, String label, String subtitle) get _header {
    return switch (status) {
      OfferStatus.pending => (
        Icons.schedule_rounded,
        AppColors.orange500,
        'Offer Pending',
        'Your offer is waiting for the citizen\'s response',
      ),
      OfferStatus.accepted => (
        Icons.check_circle_rounded,
        AppColors.green700,
        'Offer Accepted',
        'The citizen has accepted your collection offer',
      ),
      OfferStatus.rejected => (
        Icons.cancel_rounded,
        AppColors.red500,
        'Offer Rejected',
        'The citizen has declined your collection offer',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final h = _header;

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
                      color: AppColors.shadowMd,
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                          child: _buildSheetHeader(context, h),
                        ),
                        const SizedBox(height: 18),
                        Container(height: 1, color: AppColors.grey100),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                          child: _buildInfoCard(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                          child: _buildDetailsSection(),
                        ),
                        if (status == OfferStatus.accepted)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                            child: _buildPickupDetails(),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                          child: _buildBanner(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                          child: _buildAction(context),
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

  Widget _buildSheetHeader(
    BuildContext context,
    (IconData, Color, String, String) h,
  ) {
    final (icon, color, label, subtitle) = h;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodySm),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200, width: 1),
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
              color: AppColors.green800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMd),
                const SizedBox(height: 4),
                Text(
                  '$location • $distance',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySm,
                    children: [
                      const TextSpan(text: 'Citizen: '),
                      TextSpan(
                        text: _shortName(person),
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

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offer Details',
          style: AppTypography.labelMd.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildRow(
                Icons.location_on_outlined,
                'Location',
                '$location • $distance',
              ),
              const SizedBox(height: 10),
              _buildRow(
                Icons.schedule_rounded,
                'Sent',
                postedAgo,
              ),
              const SizedBox(height: 10),
              _buildRow(
                Icons.hourglass_top_rounded,
                'Status',
                switch (status) {
                  OfferStatus.pending => 'Waiting for response',
                  OfferStatus.accepted => 'Accepted by citizen',
                  OfferStatus.rejected => 'Declined by citizen',
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Information',
          style: AppTypography.labelMd.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.emerald50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.emerald100, width: 1),
          ),
          child: Column(
            children: [
              if (pickup != null) ...[
                _buildRow(Icons.access_time_rounded, 'Pickup', pickup!),
                const SizedBox(height: 10),
              ],
              if (contact != null) ...[
                _buildRow(Icons.phone_outlined, 'Contact', contact!),
                const SizedBox(height: 10),
              ],
              if (address != null)
                _buildRow(Icons.location_on_outlined, 'Address', address!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: AppColors.grey500, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySm.copyWith(color: AppColors.grey700),
              children: [
                TextSpan(
                  text: '$label:  ',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    final (Color bg, Color border, Color fg, IconData icon, String text) =
        switch (status) {
      OfferStatus.pending => (
        AppColors.yellowOrange,
        AppColors.orange200,
        AppColors.orange500,
        Icons.hourglass_bottom_rounded,
        'The citizen will be notified. You\'ll receive an update once they respond.',
      ),
      OfferStatus.accepted => (
        AppColors.emerald50,
        AppColors.emerald200,
        AppColors.green800,
        Icons.info_outline_rounded,
        'Prepare for the scheduled pickup. Contact the citizen if you need to coordinate.',
      ),
      OfferStatus.rejected => (
        AppColors.grey50,
        AppColors.grey200,
        AppColors.grey600,
        Icons.lightbulb_outline_rounded,
        'You can browse for other available collection requests nearby.',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, color: fg, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.captionSm.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    final (
      String label,
      Color bg,
      Color fg,
      Color border,
      IconData icon,
    ) = switch (status) {
      OfferStatus.pending => (
        'Cancel Offer',
        Colors.white,
        AppColors.orange500,
        AppColors.orange200,
        Icons.close_rounded,
      ),
      OfferStatus.accepted => (
        'Cancel Offer',
        Colors.white,
        AppColors.red500,
        AppColors.red100,
        Icons.close_rounded,
      ),
      OfferStatus.rejected => (
        'Remove from List',
        Colors.white,
        AppColors.grey600,
        AppColors.grey200,
        Icons.delete_outline_rounded,
      ),
    };
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(true),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: fg, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.buttonMd.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _SheetRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.scrim,
        barrierLabel: 'Dismiss',
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 850),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth slide — same feel for open and close
          final slide = Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeOutCubic,
          ));

          // Scrim (background dim) fades in/out smoothly
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
              SlideTransition(
                position: slide,
                child: child,
              ),
            ],
          );
        },
      );
}
