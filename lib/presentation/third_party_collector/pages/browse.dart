import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';

class ThirdPartyBrowsePage extends StatelessWidget {
  const ThirdPartyBrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'Browse',
            subtitle: 'Find pickup requests nearby',
          ),
          Expanded(
            child: Center(
              child: Text('Browse - Placeholder', style: AppTypography.bodyMd),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 1),
    );
  }
}
