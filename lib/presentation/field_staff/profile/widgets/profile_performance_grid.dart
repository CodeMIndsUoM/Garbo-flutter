import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

class ProfilePerformanceGrid extends StatelessWidget {
  const ProfilePerformanceGrid({super.key});

  Future<_PerformanceStats> _loadPerformanceStats() async {
    final apiService = ApiService();
    try {
      final empId = await apiService.getStoredEmpId();
      if (empId.trim().isEmpty) {
        return const _PerformanceStats(
          binsReported: 0,
          reportsToday: 0,
          avgResponseMinutes: null,
        );
      }

      final bins = await apiService.getAssignedBins(empId);
      final now = DateTime.now();

      final binsReported = bins.where((bin) => bin.status != BinStatus.notChecked).length;
      final reportsTodayBins = bins.where((bin) {
        final checkedAt = bin.lastChecked;
        if (checkedAt == null) return false;
        final local = checkedAt.toLocal();
        return local.year == now.year &&
            local.month == now.month &&
            local.day == now.day;
      }).toList();

      int? avgResponseMinutes;
      if (reportsTodayBins.isNotEmpty) {
        final totalMinutes = reportsTodayBins
            .map((bin) => now.difference(bin.lastChecked!.toLocal()).inMinutes)
            .fold<int>(0, (sum, item) => sum + item);
        avgResponseMinutes = (totalMinutes / reportsTodayBins.length).round();
      }

      return _PerformanceStats(
        binsReported: binsReported,
        reportsToday: reportsTodayBins.length,
        avgResponseMinutes: avgResponseMinutes,
      );
    } catch (_) {
      return const _PerformanceStats(
        binsReported: 0,
        reportsToday: 0,
        avgResponseMinutes: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PerformanceStats>(
      future: _loadPerformanceStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            const _PerformanceStats(
              binsReported: 0,
              reportsToday: 0,
              avgResponseMinutes: null,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppColors.grey900, size: 20),
                const SizedBox(width: 8),
                Text('Performance Stats', style: AppTypography.titleLg),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    value: '${stats.binsReported}',
                    label: 'Bins Reported',
                    valueColor: AppColors.green700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    value: '${stats.reportsToday}',
                    label: 'Reports Today',
                    valueColor: AppColors.green700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    value: stats.avgResponseMinutes == null
                        ? '--'
                        : '${stats.avgResponseMinutes!} mins',
                    label: 'Avg Response',
                    valueColor: AppColors.green700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    // TODO(next phase): Integrate backend endpoint for field mentor team ranking.
                    value: '--',
                    label: 'Team Rank',
                    valueColor: AppColors.green700,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: AppColors.grey100),
          borderRadius: BorderRadius.circular(14),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: AppTypography.h1.copyWith(color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.grey600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PerformanceStats {
  final int binsReported;
  final int reportsToday;
  final int? avgResponseMinutes;

  const _PerformanceStats({
    required this.binsReported,
    required this.reportsToday,
    required this.avgResponseMinutes,
  });
}
