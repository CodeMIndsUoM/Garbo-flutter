import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/collection_team/pages/settings.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.green700,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey500.withOpacity(0.4),
            offset: const Offset(0, 10),
            blurRadius: 15,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection Team',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hello, Mike !',
                      style: TextStyle(
                        color: AppColors.white90,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.menu, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                HeaderStat('0/8', 'Collected', null),
                const SizedBox(width: 17),
                HeaderStat('2340', 'Points', Icons.bolt),
                const SizedBox(width: 17),
                HeaderStat(
                  '24',
                  'Day Streak',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const HeaderStat(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return buildHeaderStat(value, label, icon);
  }

  Widget buildHeaderStat(String value, String label, IconData? icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
