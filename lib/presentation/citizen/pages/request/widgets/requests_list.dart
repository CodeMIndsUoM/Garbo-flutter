import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_helpers.dart';

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
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.grey400),
            SizedBox(height: 12),
            Text(
              'No requests yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Create your first collection request and nearby third-party collectors will start sending offers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey600,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (filteredRequests.isEmpty) {
      return Column(
        children: [
          filterBar,
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 12),
                Text(
                  'No matches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Try changing the status, waste type, or search terms.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
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
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: canOpenOffers ? () => onRequestTap(request) : null,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(12),
                        image: request.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(request.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: request.photoUrl == null
                          ? Icon(
                              iconForWasteType(request.wasteType),
                              color: AppColors.grey700,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  request.wasteType.replaceAll('_', ' '),
                                  style: const TextStyle(
                                    color: AppColors.citizenGrey900,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: style.bg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  style.label,
                                  style: TextStyle(
                                    color: style.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.citizenGrey600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  requestSubtitle(request),
                                  style: const TextStyle(
                                    color: AppColors.citizenGrey600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatRequestDate(request.preferredDate),
                                style: const TextStyle(
                                  color: AppColors.citizenGrey500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (request.offersCount > 0)
                                const Text(
                                  'View offers',
                                  style: TextStyle(
                                    color: AppColors.emerald600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.green700,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tap any open request with offers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.citizenGrey900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'You can review collector price proposals and accept the one that fits best.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.citizenGrey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
