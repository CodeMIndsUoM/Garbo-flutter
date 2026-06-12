import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/providers/theme_provider.dart';

/// Appearance picker for the profile tab — lets the user switch between
/// System default, Light, and Dark themes.
class ProfileAppearanceSection extends StatelessWidget {
  const ProfileAppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.brightness_6_outlined,
                color: AppColors.grey900,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Appearance', style: AppTypography.titleLg),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppDecorations.card(),
            child: Column(
              children: [
                _AppearanceOption(
                  icon: Icons.brightness_auto_outlined,
                  label: 'System default',
                  subtitle: 'Follow your device theme',
                  selected: themeProvider.mode == ThemeMode.system,
                  onTap: () => themeProvider.setMode(ThemeMode.system),
                ),
                const _OptionDivider(),
                _AppearanceOption(
                  icon: Icons.light_mode_outlined,
                  label: 'Light',
                  subtitle: 'Always use the light theme',
                  selected: themeProvider.mode == ThemeMode.light,
                  onTap: () => themeProvider.setMode(ThemeMode.light),
                ),
                const _OptionDivider(),
                _AppearanceOption(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark',
                  subtitle: 'Always use the dark theme',
                  selected: themeProvider.mode == ThemeMode.dark,
                  onTap: () => themeProvider.setMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.green700 : AppColors.grey500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.green700 : AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? AppColors.green700 : AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionDivider extends StatelessWidget {
  const _OptionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppColors.grey100);
  }
}
