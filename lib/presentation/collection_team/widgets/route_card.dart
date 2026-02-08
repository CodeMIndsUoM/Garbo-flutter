import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';
import '../models/route_models.dart';
import 'bin_item_widget.dart';
import 'high_priority_badge.dart';

/// An expandable route card that shows route info, progress, and bin details.
class RouteCard extends StatelessWidget {
  final RouteData route;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final List<BinData> bins;

  const RouteCard({
    super.key,
    required this.route,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.bins,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority = route.status == RouteStatus.highPriority;
    final double progressPercent = route.totalBins > 0
        ? route.progress / route.totalBins
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 12),
      decoration: BoxDecoration(
        gradient: isHighPriority
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DesignTokens.red50, DesignTokens.orange50],
              )
            : null,
        color: isHighPriority ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighPriority ? DesignTokens.red100 : DesignTokens.grey200,
          width: 1.275,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            route: route,
            isExpanded: isExpanded,
            onToggleExpand: onToggleExpand,
          ),
          const SizedBox(height: 12),
          _ProgressSection(route: route, progressPercent: progressPercent),
          if (route.status != RouteStatus.completed) ...[
            const SizedBox(height: 12),
            _StartRouteButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Starting route...'),
                    duration: Duration(seconds: 1),
                    backgroundColor: DesignTokens.green700,
                  ),
                );
              },
            ),
          ],
          // Expandable Route Details — dissolve animation
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(height: 1, color: DesignTokens.grey200),
                          _RouteDetailsSection(bins: bins),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header row with badges + expand chevron ─────────────────────

class _HeaderRow extends StatelessWidget {
  final RouteData route;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _HeaderRow({
    required this.route,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badges
              Row(
                children: [
                  _StatusBadge(status: route.status),
                  const SizedBox(width: 8),
                  _RouteBadge(routeId: route.id),
                ],
              ),
              const SizedBox(height: 8),
              // Route name
              Text(
                route.name,
                style: const TextStyle(
                  color: DesignTokens.grey900,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              // Route details chips
              Row(
                children: [
                  _DetailChip(
                    icon: Icons.delete_outline,
                    text: '${route.bins} bins',
                  ),
                  const SizedBox(width: 16),
                  _DetailChip(
                    icon: Icons.location_on_outlined,
                    text: '${route.distance} km',
                  ),
                  const SizedBox(width: 16),
                  _DetailChip(
                    icon: Icons.access_time,
                    text: '${route.duration} mins',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Expand button
        GestureDetector(
          onTap: onToggleExpand,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: DesignTokens.grey600,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Small badge widgets ─────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final RouteStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == RouteStatus.highPriority) {
      return const HighPriorityBadge();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignTokens.grey200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'PENDING',
        style: TextStyle(
          color: DesignTokens.grey700,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  final String routeId;
  const _RouteBadge({required this.routeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignTokens.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        routeId,
        style: const TextStyle(
          color: DesignTokens.grey600,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: DesignTokens.grey600, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: DesignTokens.grey600,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Progress section ────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final RouteData route;
  final double progressPercent;
  const _ProgressSection({required this.route, required this.progressPercent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: DesignTokens.grey600,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '${route.progress}/${route.totalBins}',
                style: const TextStyle(
                  color: DesignTokens.grey900,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: DesignTokens.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                DesignTokens.green700,
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Start Route button ──────────────────────────────────────────

class _StartRouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StartRouteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, size: 16),
            SizedBox(width: 6),
            Text(
              'Start Route',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Route Details (bin list) ────────────────────────────────────

class _RouteDetailsSection extends StatelessWidget {
  final List<BinData> bins;
  const _RouteDetailsSection({required this.bins});

  @override
  Widget build(BuildContext context) {
    final int urgentCount = bins.where((b) => b.isUrgent).length;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Details',
                style: TextStyle(
                  color: DesignTokens.grey900,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (urgentCount > 0)
                Text(
                  '$urgentCount urgent',
                  style: const TextStyle(
                    color: DesignTokens.red500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...bins.asMap().entries.map((entry) {
            return BinItemWidget(
              bin: entry.value,
              index: entry.key + 1,
              isLast: entry.key == bins.length - 1,
            );
          }),
        ],
      ),
    );
  }
}
