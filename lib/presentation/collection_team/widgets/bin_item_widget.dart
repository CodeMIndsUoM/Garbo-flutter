import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';
import '../models/route_models.dart';

/// A single bin item row displayed inside the route details section.
class BinItemWidget extends StatelessWidget {
  final BinData bin;
  final int index;
  final bool isLast;

  const BinItemWidget({
    super.key,
    required this.bin,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bin.isUrgent ? DesignTokens.red50 : DesignTokens.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bin.isUrgent
              ? DesignTokens.red100.withValues(alpha: 0.5)
              : DesignTokens.grey200,
          width: 1.3,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rounded rectangle index badge
          _IndexBadge(index: index),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BadgeRow(bin: bin),
                const SizedBox(height: 6),
                // Bin name
                Text(
                  bin.name,
                  style: const TextStyle(
                    color: DesignTokens.grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                // Address
                Text(
                  bin.address,
                  style: const TextStyle(
                    color: DesignTokens.grey600,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                // Info row: distance, time, fill status
                _InfoRow(bin: bin),
                // Next / ETA row
                if (bin.nextDistance != null && bin.nextEta != null) ...[
                  const SizedBox(height: 8),
                  _NextEtaRow(
                    nextDistance: bin.nextDistance!,
                    nextEta: bin.nextEta!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ─────────────────────────────────────────

class _IndexBadge extends StatelessWidget {
  final int index;
  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DesignTokens.grey300, width: 1.3),
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: const TextStyle(
          color: DesignTokens.grey700,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final BinData bin;
  const _BadgeRow({required this.bin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (bin.isUrgent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: DesignTokens.red500,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'URGENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: DesignTokens.grey200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            bin.id,
            style: const TextStyle(
              color: DesignTokens.grey600,
              fontSize: 9,
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
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 12,
          color: DesignTokens.grey500,
        ),
        const SizedBox(width: 4),
        Text(
          '${bin.distance} km',
          style: const TextStyle(
            color: DesignTokens.grey500,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.access_time, size: 12, color: DesignTokens.grey500),
        const SizedBox(width: 4),
        Text(
          '${bin.duration} mins',
          style: const TextStyle(
            color: DesignTokens.grey500,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 12),
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
        color: isFull ? DesignTokens.red500 : DesignTokens.orange600,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isFull ? 'FULL' : 'HALF',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
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
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DesignTokens.grey200, width: 1.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 12,
            color: DesignTokens.blue500,
          ),
          const SizedBox(width: 4),
          Text(
            'Next: $nextDistance km',
            style: const TextStyle(
              color: DesignTokens.blue500,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.access_time, size: 12, color: DesignTokens.blue500),
          const SizedBox(width: 4),
          Text(
            'ETA: $nextEta mins',
            style: const TextStyle(
              color: DesignTokens.blue500,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
