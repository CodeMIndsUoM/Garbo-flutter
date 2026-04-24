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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<LeaderboardProvider>().loadSnapshot();
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
                final userEntry = leaderboardProvider.getUserRank(
                  authProvider.currentUser?.empId ?? 0,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Collection Team Leaderboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Top performers this week',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Current user rank card (if in top 10)
                      if (userEntry != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.blue50, AppColors.indigo50],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.blue200,
                              width: 1.27,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.blue500,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${userEntry.rank}',
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
                                      userEntry.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${userEntry.rewardPoints.toStringAsFixed(0)} points',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.green700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber[700]),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You\'re not in the top 10 yet. Keep collecting!',
                                  style: TextStyle(
                                    color: Colors.amber[900],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 32),

                      // Leaderboard list
                      Text(
                        'Top 10 Collectors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Leaderboard entries
                      ...entries.asMap().entries.map((entry) {
                        final index = entry.key;
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
                                // Rank badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _getRankColor(index),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                // User info
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
                                      SizedBox(height: 2),
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
                                // Points
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
                                    SizedBox(height: 2),
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
          ? 'id:${entry.userId}'
          : 'name:${entry.name.toLowerCase()}|role:${entry.role.toLowerCase()}';
      if (seenKeys.contains(key)) {
        continue;
      }
      seenKeys.add(key);
      unique.add(entry);
    }

    final normalizedNameCounts = <String, int>{};
    final renamed = <LeaderboardEntryDto>[];
    for (final entry in unique) {
      final normalizedName = entry.name.trim().toLowerCase();
      final seenCount = normalizedNameCounts[normalizedName] ?? 0;
      normalizedNameCounts[normalizedName] = seenCount + 1;

      if (seenCount == 0) {
        renamed.add(entry);
        continue;
      }

      final alias = _generateRandomAlias(entry, seenCount);
      renamed.add(
        LeaderboardEntryDto(
          rank: entry.rank,
          userId: entry.userId,
          name: alias,
          rewardPoints: entry.rewardPoints,
          role: entry.role,
          rankChangeFromPrevious: entry.rankChangeFromPrevious,
        ),
      );
    }

    final needed = 10 - renamed.length;
    for (var i = 0; i < needed; i++) {
      final name = 'Collector User ${i + 1}';
      renamed.add(
        LeaderboardEntryDto(
          rank: renamed.length + 1,
          userId: null,
          name: name,
          rewardPoints: 0,
          role: 'COLLECTOR',
          rankChangeFromPrevious: null,
        ),
      );
    }

    return renamed.take(10).toList(growable: false);
  }

  String _generateRandomAlias(LeaderboardEntryDto entry, int duplicateIndex) {
    const firstNames = [
      'Nalin',
      'Kavindu',
      'Shehan',
      'Dinuka',
      'Sahan',
      'Ravindu',
      'Tharindu',
      'Kasun',
      'Mithun',
      'Janith',
    ];
    const lastNames = [
      'Perera',
      'Silva',
      'Fernando',
      'Jayasinghe',
      'Kumara',
      'Bandara',
      'Wijesinghe',
      'Ranasinghe',
      'De Silva',
      'Karunaratne',
    ];

    final seed = (entry.userId ?? entry.rank) + duplicateIndex;
    final first = firstNames[seed % firstNames.length];
    final last = lastNames[(seed * 3) % lastNames.length];
    return '$first $last';
  }
}
