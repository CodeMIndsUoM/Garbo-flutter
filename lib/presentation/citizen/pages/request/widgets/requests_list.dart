import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_helpers.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';

/// Displays the list of citizen collection requests with filter bar support.
class RequestsList extends StatelessWidget {
  final bool loading;
  final List<CollectionRequestModel> allRequests;
  final List<CollectionRequestModel> filteredRequests;
  final Widget filterBar;
  final ValueChanged<CollectionRequestModel> onRequestTap;

  const RequestsList({
    super.key,
    required this.loading,
    required this.allRequests,
    required this.filteredRequests,
    required this.filterBar,
    required this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (allRequests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No requests yet. Create your first collection request to receive offers from collectors.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
          ),
        ),
      );
    }

    if (filteredRequests.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          filterBar,
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No matching requests. Try changing your filters.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filterBar,
        ...filteredRequests.map((request) {
          final style = statusStyle(request.status);
          final canOpenOffers =
              request.offersCount > 0 ||
              request.status == 'OPEN' ||
              request.status == 'ASSIGNED';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: canOpenOffers ? () => onRequestTap(request) : null,
                child: CitizenSurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        iconForWasteType(
                          request.wasteTypes.isNotEmpty
                              ? request.wasteTypes.first
                              : request.wasteType,
                        ),
                        color: AppColors.green700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wasteTypesLabel(request),
                              style: AppTypography.titleSm,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              requestSubtitle(request),
                              style: AppTypography.bodySm,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRequestDate(request.preferredDate),
                              style: AppTypography.bodySm,
                            ),
                            if (request.offersCount > 0) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${request.offersCount} offer${request.offersCount == 1 ? '' : 's'} · Tap to review',
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          style.label,
                          style: AppTypography.captionSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: style.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
