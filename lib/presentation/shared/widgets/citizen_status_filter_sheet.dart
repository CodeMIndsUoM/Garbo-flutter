import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_filter_chip.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

typedef StatusFilterOption = (String value, String label);

/// Bottom sheet with status chips for list filtering.
Future<void> showCitizenStatusFilterSheet({
  required BuildContext context,
  required String currentStatus,
  required ValueChanged<String> onApply,
  List<StatusFilterOption>? options,
}) async {
  final statusOptions = options ??
      const [
        ('ALL', 'All'),
        ('PENDING', 'Pending'),
        ('APPROVED', 'Approved'),
        ('ACCEPTED', 'Accepted'),
        ('REJECTED', 'Rejected'),
        ('RESOLVED', 'Resolved'),
      ];

  var localStatus = currentStatus;

  final shouldApply = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('Filters', style: AppTypography.titleLg),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            setSheetState(() => localStatus = 'ALL'),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Status', style: AppTypography.labelMd),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (value, label) in statusOptions)
                        CitizenFilterChip(
                          label: label,
                          selected: localStatus == value,
                          onSelected: (_) =>
                              setSheetState(() => localStatus = value),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Apply Filters'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emerald600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (shouldApply == true) {
    onApply(localStatus);
  }
}
