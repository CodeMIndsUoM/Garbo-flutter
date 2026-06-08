import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/leaderboard_content.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const LeaderboardContent(showHeader: false),
    );
  }
}
