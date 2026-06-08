import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
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
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current rankings by score',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: userEntry != null
                        ? [AppColors.blue50, AppColors.indigo50]
                        : [Colors.grey[50]!, Colors.grey[100]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: userEntry != null
                            ? AppColors.blue500
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          userEntry != null ? '#${userEntry.rank}' : '—',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEntry?.name ??
                                authProvider.currentUser?.empName ??
                                'Loading...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEntry != null
                                ? '${userEntry.rewardPoints.toStringAsFixed(0)} points'
                                : 'Calculating...',
                            style: TextStyle(
                              fontSize: 14,
                              color: userEntry != null
                                  ? AppColors.green700
                                  : Colors.grey[600],
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
              const Text(
                'Top 10 Earners',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
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
                          style: const TextStyle(
                            fontSize: 14,
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                      decoration: BoxDecoration(
                        color: isCurrentUser ? AppColors.blue50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.transparent),
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.role == 'COLLECTOR'
                                      ? 'Bin Collector'
                                      : 'Field Mentor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (item.rankChangeFromPrevious != null)
                                Text(
                                  leaderboardProvider.getRankChangeIndicator(
                                    item,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
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
