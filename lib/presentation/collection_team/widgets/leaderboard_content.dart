import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';

class LeaderboardContent extends StatefulWidget {
  const LeaderboardContent({
    super.key,
    this.showHeader = true,
    this.padding = const EdgeInsets.all(24),
  });

  final bool showHeader;
  final EdgeInsets padding;

  @override
  State<LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<LeaderboardContent> {
  int? _initializedForUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _primeLeaderboard(forceReload: true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _primeLeaderboard();
    });
  }

  void _primeLeaderboard({bool forceReload = false}) {
    final authProvider = context.read<AuthProvider>();
    final leaderboardProvider = context.read<LeaderboardProvider>();
    final currentUserId = authProvider.currentUser?.empId;
    final role = authProvider.currentUser?.role ?? 'COLLECTOR';

    if (!forceReload && _initializedForUserId == currentUserId) {
      return;
    }

    _initializedForUserId = currentUserId;
    leaderboardProvider.trackUser(currentUserId, role: role);
    if (forceReload) {
      leaderboardProvider.loadSnapshot();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LeaderboardProvider, AuthProvider>(
      builder: (context, leaderboardProvider, authProvider, _) {
        final entries = _buildDisplayEntries(
          leaderboardProvider.getTopEntries(10),
        );
        final userEntry = leaderboardProvider.userRankEntry;

        return SingleChildScrollView(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                Text('Leaderboard', style: AppTypography.displayLg),
                const SizedBox(height: 8),
                Text(
                  'Current rankings by score',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.grey600),
                ),
                const SizedBox(height: 24),
              ],
              CitizenSurfaceCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: userEntry != null
                            ? AppColors.blue500
                            : AppColors.grey400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          userEntry != null ? '#${userEntry.rank}' : '—',
                          style: AppTypography.displaySm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Rank',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEntry?.name ??
                                authProvider.currentUser?.empName ??
                                'Loading...',
                            style: AppTypography.titleLg,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEntry != null
                                ? '${userEntry.rewardPoints.toStringAsFixed(0)} points'
                                : 'Calculating...',
                            style: AppTypography.bodyMd.copyWith(
                              color: userEntry != null
                                  ? AppColors.green700
                                  : AppColors.grey600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Top 10 Earners', style: AppTypography.h3),
              const SizedBox(height: 16),
              if (leaderboardProvider.isLoadingSnapshot && entries.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (leaderboardProvider.errorMessage != null &&
                  entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(
                          leaderboardProvider.errorMessage!,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.red500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => leaderboardProvider.loadSnapshot(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No earners available yet.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                )
              else
                ...entries.map((item) {
                  final isCurrentUser =
                      item.userId == authProvider.currentUser?.empId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: AppDecorations.card(
                        color: isCurrentUser ? AppColors.blue50 : AppColors.surface,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getRankColor(item.rank - 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${item.rank}',
                                style: AppTypography.titleLg.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: AppTypography.titleSm),
                                const SizedBox(height: 2),
                                Text(
                                  item.role == 'COLLECTOR'
                                      ? 'Bin Collector'
                                      : 'Field Mentor',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.rewardPoints.toStringAsFixed(0),
                                style: AppTypography.titleLg.copyWith(
                                  color: AppColors.green700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (item.rankChangeFromPrevious != null)
                                Text(
                                  leaderboardProvider.getRankChangeIndicator(
                                    item,
                                  ),
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Color(
                                      leaderboardProvider.getRankChangeColor(
                                        item,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Last updated: ${leaderboardProvider.lastUpdateFormatted}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.yellow400;
      case 1:
        return AppColors.grey400;
      case 2:
        return AppColors.amber600;
      default:
        return AppColors.blue500;
    }
  }

  List<LeaderboardEntryDto> _buildDisplayEntries(
    List<LeaderboardEntryDto> source,
  ) {
    final unique = <LeaderboardEntryDto>[];
    final seenKeys = <String>{};

    for (final entry in source) {
      final key = entry.userId != null
          ? 'id:${entry.userId}|role:${entry.role.toLowerCase()}'
          : 'name:${entry.name.toLowerCase()}|role:${entry.role.toLowerCase()}';
      if (seenKeys.add(key)) {
        unique.add(entry);
      }
    }

    return unique.take(10).toList(growable: false);
  }
}
