import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';

/// Bottom sheet that displays all offers for a collection request.
class RequestOffersSheet extends StatelessWidget {
  final CollectionRequestModel request;
  final Future<void> Function(CollectionOfferModel offer) onAccept;
  final Future<void> Function(CollectionOfferModel offer) onReject;
  final Future<void> Function(CollectionOfferModel offer) onConfirm;

  const RequestOffersSheet({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onConfirm,
  });

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$date  $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.wasteType.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.addressLine,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald200),
                  ),
                  child: Text(
                    request.offers.isEmpty
                        ? 'No offers yet. Collectors will appear here once they respond.'
                        : '${request.offers.length} collector offer${request.offers.length == 1 ? '' : 's'} available for this request.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.emerald900,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...request.offers.map((offer) {
                  final pending =
                      offer.status == 'PENDING' && request.status == 'OPEN';
                  final accepted = offer.status == 'ACCEPTED';
                  final completedUnrated =
                      offer.status == 'COMPLETED' && offer.citizenRating == null;
                  final rated = offer.citizenRating != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                offer.collectorName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accepted
                                    ? AppColors.emerald200
                                    : AppColors.grey200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                offer.status.toLowerCase(),
                                style: TextStyle(
                                  color: accepted
                                      ? AppColors.emerald900
                                      : AppColors.grey700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((offer.collectorCompany ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            offer.collectorCompany!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              offer.pricePerUnit != null
                                  ? Icons.payments_outlined
                                  : Icons.swap_horiz_outlined,
                              size: 16,
                              color: AppColors.emerald600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                offer.pricePerUnit != null
                                    ? 'LKR ${offer.pricePerUnit!.toStringAsFixed(2)} (${offer.priceUnit})'
                                    : 'Exchange for: ${offer.exchangeItem ?? "Unknown"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: AppColors.blue600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDateTime(offer.proposedPickupAt),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        if ((offer.messageToCitizen ?? '').isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            offer.messageToCitizen!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey700,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (pending) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => onReject(offer),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.grey700,
                                    side: const BorderSide(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => onAccept(offer),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald600,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (completedUnrated) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => onConfirm(offer),
                              icon: const Icon(Icons.star_rounded, size: 18),
                              label: const Text('Rate & Confirm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                        if (rated) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (var i = 1; i <= 5; i++)
                                Icon(
                                  i <= offer.citizenRating!
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: AppColors.amber600,
                                  size: 18,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                '${offer.citizenRating}/5',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ],
                          ),
                          if ((offer.citizenFeedback ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              offer.citizenFeedback!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
