import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/leaderboard_content.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        foregroundColor: AppColors.grey900,
        elevation: 0,
        title: Text('Leaderboard', style: AppTypography.titleLg),
      ),
      body: const LeaderboardContent(showHeader: false),
    );
  }
}
