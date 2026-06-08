import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
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
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No requests yet. Create your first collection request to receive offers from collectors.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    if (filteredRequests.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          filterBar,
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No matching requests. Try changing your filters.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.grey600),
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
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wasteTypesLabel(request),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              requestSubtitle(request),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRequestDate(request.preferredDate),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (request.offersCount > 0) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${request.offersCount} offer${request.offersCount == 1 ? '' : 's'} · Tap to review',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
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
                          style: TextStyle(
                            fontSize: 11,
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
