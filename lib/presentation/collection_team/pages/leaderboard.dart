import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final authProvider = context.read<AuthProvider>();
      final leaderboardProvider = context.read<LeaderboardProvider>();
      final currentUserId = authProvider.currentUser?.empId;
      if (_initializedForUserId == currentUserId) {
        return;
      }
      _initializedForUserId = currentUserId;
      leaderboardProvider.trackUser(
        currentUserId,
        role: authProvider.currentUser?.role,
      );
      leaderboardProvider.loadSnapshot();
      
      // Fetch user's current rank
      if (currentUserId != null) {
        leaderboardProvider.fetchUserRank(
          currentUserId.toInt(),
          role: authProvider.currentUser?.role,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          // Header(),
          Expanded(
            child: Consumer2<LeaderboardProvider, AuthProvider>(
              builder: (context, leaderboardProvider, authProvider, _) {
                final entries = _buildDisplayEntries(
                  leaderboardProvider.getTopEntries(10),
                );
                final userEntry = leaderboardProvider.userRankEntry;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Current rankings by score',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Current user rank card
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
                          border: Border.all(
                            color: userEntry != null
                                ? AppColors.blue200
                                : Colors.grey[300]!,
                            width: 1.27,
                          ),
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
                                  userEntry != null
                                      ? '#${userEntry.rank}'
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
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
                                  SizedBox(height: 4),
                                  Text(
                                    userEntry?.name ??
                                        authProvider.currentUser?.empName ??
                                        'Loading...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
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

                      SizedBox(height: 32),

                      // Leaderboard list
                      Text(
                        'Top 10 Earners',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 16),

                      if (leaderboardProvider.isLoadingSnapshot &&
                          entries.isEmpty)
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.red500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () =>
                                      leaderboardProvider.loadSnapshot(),
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
                        ...entries.asMap().entries.map((entry) {
                          final item = entry.value;
                          final isCurrentUser =
                              item.userId == authProvider.currentUser?.empId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? AppColors.blue50
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentUser
                                      ? AppColors.blue200
                                      : Colors.grey[200]!,
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.green700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (item.rankChangeFromPrevious != null)
                                        Text(
                                          leaderboardProvider
                                              .getRankChangeIndicator(item),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(leaderboardProvider
                                                .getRankChangeColor(item)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      SizedBox(height: 16),
                      // Last update time
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
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for rank badge
  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Color(0xFFFFD700); // Gold
      case 1:
        return Color(0xFFC0C0C0); // Silver
      case 2:
        return Color(0xFFCD7F32); // Bronze
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
