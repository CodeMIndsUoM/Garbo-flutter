import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/collection_team/pages/leaderboard.dart';

class LevelProgressCard extends StatelessWidget {
  final LeaderboardEntryDto? userEntry;
  final int level;
  final double points;
  final double levelProgress;
  final double pointsToNextLevel;

  const LevelProgressCard({
    super.key,
    required this.userEntry,
    required this.level,
    required this.points,
    required this.levelProgress,
    required this.pointsToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final rankText = userEntry?.rank != null ? '#${userEntry!.rank}' : '--';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LeaderboardPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: AppDecorations.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.green700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Level $level', style: AppTypography.h3),
                          Text(
                            'Current Rank $rankText',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${points.toStringAsFixed(0)} pts',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.green700,
                        ),
                      ),
                      Text(
                        '${pointsToNextLevel.toStringAsFixed(0)} to Level ${level + 1}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: AppColors.grey200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.green700,
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level rule: every 250 points increases 1 level.',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
