import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs/utils/my_jobs_helpers.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/offer_details_sheet.dart';

/// Card for a single offer in the "My Offers" tab.
class OfferCard extends StatelessWidget {
  final CollectionOfferModel offer;
  final CollectionRequestModel? request;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.offer,
    required this.request,
    required this.onTap,
  });

  OfferStatus _toSheetStatus(String status) {
    if (status == 'PENDING') return OfferStatus.pending;
    if (status == 'ACCEPTED' || status == 'IN_PROGRESS') {
      return OfferStatus.accepted;
    }
    return OfferStatus.rejected;
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final sheetStatus = _toSheetStatus(offer.status);
    final (
      Color badgeBg,
      Color badgeFg,
      String badgeLabel,
    ) = switch (sheetStatus) {
      OfferStatus.pending => (AppColors.grey100, AppColors.grey600, 'Pending'),
      OfferStatus.accepted => (
        AppColors.emerald50,
        AppColors.green800,
        'Accepted',
      ),
      OfferStatus.rejected => (
        AppColors.grey100,
        AppColors.grey500,
        'Rejected',
      ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.emerald50,
        child: Ink(
          decoration: AppDecorations.card(),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImageSlot(request?.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request == null
                                ? 'Request #${offer.requestId}'
                                : '${request!.wasteType.replaceAll('_', ' ')} Waste',
                            style: AppTypography.titleMd,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeLabel,
                            style: AppTypography.captionSm.copyWith(
                              color: badgeFg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request?.citizenName ?? 'Citizen',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.green700,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request?.addressLine ?? 'Location unavailable',
                            style: AppTypography.captionSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          postedAgoLabel(offer.createdAt),
                          style: AppTypography.captionSm.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey300,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for an active job with navigate/complete actions.
class ActiveJobCard extends StatelessWidget {
  final CollectionOfferModel offer;
  final CollectionRequestModel? request;
  final VoidCallback onNavigate;
  final VoidCallback onComplete;

  const ActiveJobCard({
    super.key,
    required this.offer,
    required this.request,
    required this.onNavigate,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final wasteLabel = request == null
        ? 'Request #${offer.requestId}'
        : '${request!.wasteType.replaceAll('_', ' ')} Waste';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImageSlot(request?.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wasteLabel, style: AppTypography.titleMd),
                    const SizedBox(height: 2),
                    Text(
                      request?.citizenName ?? 'Citizen',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.green700,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request?.addressLine ?? 'Location unavailable',
                            style: AppTypography.captionSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailsBox(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.navigation_outlined,
                  label: 'Navigate',
                  onTap: onNavigate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryButton(
                  icon: Icons.check_rounded,
                  label: 'Complete',
                  onTap: onComplete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Pickup:',
            value: formatPickup(offer.proposedPickupAt.toLocal()),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact:',
            value: request?.contactPhone ?? 'Not available',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: null,
            value: request?.addressLine ?? 'Address unavailable',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String? label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: AppColors.grey500, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySm.copyWith(color: AppColors.grey700),
              children: [
                if (label != null)
                  TextSpan(
                    text: '$label ',
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

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.green700,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.buttonMd.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.emerald50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.green800, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.buttonMd.copyWith(
                  color: AppColors.green800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared image slot used by both card types.
Widget buildImageSlot(String? imageUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 72,
      height: 72,
      color: AppColors.grey100,
      alignment: Alignment.center,
      child: imageUrl == null
          ? Icon(Icons.image_rounded, color: AppColors.grey300, size: 28)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
              cacheWidth: 216,
              cacheHeight: 216,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_rounded,
                color: AppColors.grey300,
                size: 28,
              ),
            ),
    ),
  );
}
