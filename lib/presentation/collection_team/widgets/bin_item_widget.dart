import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/route_model.dart';

/// A single bin item row displayed inside the route details section.
class BinItemWidget extends StatelessWidget {
  final BinData bin;
  final int index;
  final bool isLast;
  final BinCollectionStatus collectionStatus;
  final VoidCallback? onSkip;
  final VoidCallback? onUndo;
  final DateTime? collectedAt;

  const BinItemWidget({
    super.key,
    required this.bin,
    required this.index,
    required this.isLast,
    this.collectionStatus = BinCollectionStatus.pending,
    this.onSkip,
    this.onUndo,
    this.collectedAt,
  });

  @override
  Widget build(BuildContext context) {
    final isCollecting = collectionStatus == BinCollectionStatus.collecting;
    final isCollected = collectionStatus == BinCollectionStatus.collected;
    final isSkipped = collectionStatus == BinCollectionStatus.skipped;

    return Opacity(
      opacity: isSkipped ? 0.55 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSkipped
                ? AppColors.grey300
                : bin.isUrgent
                ? AppColors.red100.withValues(alpha: 0.5)
                : AppColors.grey200,
            width: 1.3,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded rectangle index badge
            _IndexBadge(index: index, collectionStatus: collectionStatus),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BadgeRow(bin: bin, collectionStatus: collectionStatus),
                  const SizedBox(height: 6),
                  // Bin name
                  Text(
                    bin.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSm.copyWith(
                      color: isSkipped
                          ? AppColors.grey500
                          : AppColors.grey900,
                      decoration: isSkipped ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Address
                  Text(
                    bin.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSm.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  // Info row: distance, time, fill status (hidden for collecting = compact view)
                  if (!isCollecting) ...[
                    const SizedBox(height: 8),
                    _InfoRow(bin: bin),
                  ],
                  // Next / ETA row (hidden for collecting, collected & skipped bins)
                  if (!isCollecting &&
                      !isCollected &&
                      !isSkipped &&
                      bin.nextDistance != null &&
                      bin.nextEta != null) ...[
                    const SizedBox(height: 8),
                    _NextEtaRow(
                      nextDistance: bin.nextDistance!,
                      nextEta: bin.nextEta!,
                    ),
                  ],
                  // Timestamp box for collected/skipped bins
                  if ((isCollected || isSkipped) && collectedAt != null) ...[
                    const SizedBox(height: 8),
                    _CompletionTimestamp(
                      timestamp: collectedAt!,
                      label: isSkipped ? 'Skipped' : 'Collected',
                      color: isSkipped
                          ? AppColors.grey600
                          : AppColors.green700,
                    ),
                  ],
                ],
              ),
            ),
            // Skip button for collecting bin only
            if (isCollecting && onSkip != null) ...[
              const SizedBox(width: 8),
              _SkipButton(onSkip: onSkip!),
            ],
            // Undo button for collected/skipped bins
            if ((isCollected || isSkipped) && onUndo != null) ...[
              const SizedBox(width: 8),
              _UndoButton(onUndo: onUndo!),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ─────────────────────────────────────────

class _IndexBadge extends StatelessWidget {
  final int index;
  final BinCollectionStatus collectionStatus;
  const _IndexBadge({required this.index, required this.collectionStatus});

  @override
  Widget build(BuildContext context) {
    final isCollected = collectionStatus == BinCollectionStatus.collected;
    final isSkipped = collectionStatus == BinCollectionStatus.skipped;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCollected ? AppColors.green700 : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCollected
              ? AppColors.green700
              : isSkipped
              ? AppColors.grey400
              : AppColors.grey300,
          width: 1.3,
        ),
      ),
      alignment: Alignment.center,
      child: isCollected
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : isSkipped
          ? Icon(Icons.forward, color: AppColors.grey600, size: 18)
          : Text(
              '$index',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final BinData bin;
  final BinCollectionStatus collectionStatus;
  const _BadgeRow({required this.bin, required this.collectionStatus});

  @override
  Widget build(BuildContext context) {
    final isCollecting = collectionStatus == BinCollectionStatus.collecting;
    final isCollected = collectionStatus == BinCollectionStatus.collected;
    final isSkipped = collectionStatus == BinCollectionStatus.skipped;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Collection status badge
        if (isCollecting) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.blue500,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'COLLECTING',
              style: AppTypography.badge,
            ),
          ),
        ] else if (isCollected) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.green700,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'COLLECTED',
              style: AppTypography.badge,
            ),
          ),
        ] else if (isSkipped) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forward, size: 9, color: AppColors.grey600),
                const SizedBox(width: 3),
                Text(
                  'SKIPPED',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (bin.isUrgent && !isCollected && !isSkipped) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.red500,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'URGENT',
              style: AppTypography.badge,
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            bin.id,
            style: AppTypography.badge.copyWith(
              color: AppColors.grey600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final BinData bin;
  const _InfoRow({required this.bin});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 12,
              color: AppColors.grey500,
            ),
            const SizedBox(width: 4),
            Text(
              '${bin.distance} km',
              style: AppTypography.captionSm,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 12,
              color: AppColors.grey500,
            ),
            const SizedBox(width: 4),
            Text(
              '${bin.duration} mins',
              style: AppTypography.captionSm,
            ),
          ],
        ),
        _FillStatusBadge(status: bin.fillStatus),
      ],
    );
  }
}

class _FillStatusBadge extends StatelessWidget {
  final BinFillStatus status;
  const _FillStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isFull = status == BinFillStatus.full;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFull ? AppColors.red500 : AppColors.yellow400,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isFull ? 'FULL' : 'HALF',
        style: AppTypography.overline.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NextEtaRow extends StatelessWidget {
  final double nextDistance;
  final int nextEta;
  const _NextEtaRow({required this.nextDistance, required this.nextEta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1.3),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.blue500,
              ),
              const SizedBox(width: 4),
              Text(
                'Next: $nextDistance km',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.blue500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time,
                size: 12,
                color: AppColors.blue500,
              ),
              const SizedBox(width: 4),
              Text(
                'ETA: $nextEta mins',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.blue500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Completion timestamp box ─────────────────────────────────────

class _CompletionTimestamp extends StatelessWidget {
  final DateTime timestamp;
  final String label;
  final Color color;

  const _CompletionTimestamp({
    required this.timestamp,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label == 'Skipped' ? Icons.forward : Icons.check_circle,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label $date, $time',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.overline.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skip button (shown on collecting bin) ──────────────────────

class _SkipButton extends StatelessWidget {
  final VoidCallback onSkip;
  const _SkipButton({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 77,
      height: 32,
      child: OutlinedButton(
        onPressed: onSkip,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.grey600,
          backgroundColor: AppColors.surface,
          elevation: 0,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(color: AppColors.grey300, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.skip_next_rounded, size: 12),
            const SizedBox(width: 4),
            Text(
              'Skip',
              style: AppTypography.captionSm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Undo button (shown on collected bins) ──────────────────────

class _UndoButton extends StatelessWidget {
  final VoidCallback onUndo;
  const _UndoButton({required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 77,
      height: 32,
      child: OutlinedButton(
        onPressed: onUndo,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.grey700,
          backgroundColor: AppColors.surface,
          elevation: 0,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(color: AppColors.grey300, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.undo_rounded, size: 12),
            const SizedBox(width: 4),
            Text(
              'Undo',
              style: AppTypography.captionSm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
