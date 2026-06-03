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

      final bins = await apiService.getAssignedBins();
      final now = DateTime.now();

      final binsReported = bins
          .where((bin) => bin.status != BinStatus.notChecked)
          .length;
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
        final stats =
            snapshot.data ??
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
                const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.grey900,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Performance Stats', style: AppTypography.titleLg),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey200, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSm,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildListRow(
                    label: 'Bins Reported',
                    value: '${stats.binsReported}',
                  ),
                  _buildListRow(
                    label: 'Reports Today',
                    value: '${stats.reportsToday}',
                  ),
                  _buildListRow(
                    label: 'Avg Response',
                    value: stats.avgResponseMinutes == null
                        ? '--'
                        : '${stats.avgResponseMinutes!} mins',
                  ),
                  _buildListRow(
                    label: 'Team Rank',
                    value: '--',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.titleMd.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTypography.titleMd.copyWith(
              color: AppColors.green700,
              fontWeight: FontWeight.w700,
            ),
          ),
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
