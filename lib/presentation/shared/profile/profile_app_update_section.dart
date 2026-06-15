import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/providers/app_update_provider.dart';

/// App update section on the profile tab — shows installed version and lets
/// the user check for newer releases from the backend.
class ProfileAppUpdateSection extends StatefulWidget {
  const ProfileAppUpdateSection({super.key});

  @override
  State<ProfileAppUpdateSection> createState() => _ProfileAppUpdateSectionState();
}

class _ProfileAppUpdateSectionState extends State<ProfileAppUpdateSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AppUpdateProvider>();
      if (!provider.isInitialized) {
        provider.initialize();
      } else {
        provider.refresh();
      }
    });
  }

  Future<void> _checkForUpdates() async {
    await context.read<AppUpdateProvider>().refresh();
    if (!mounted) return;

    final provider = context.read<AppUpdateProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (provider.updateAvailable) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Version ${provider.latestVersion} is available',
          ),
        ),
      );
      return;
    }

    if (provider.remoteInfo != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('You are on the latest version')),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Could not check for updates. Try again.')),
    );
  }

  Future<void> _openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the app store')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<AppUpdateProvider>();
    final current = updateProvider.currentVersion ?? '--';
    final latest = updateProvider.latestVersion;
    final notes = updateProvider.releaseNotes;
    final storeUrl = updateProvider.storeUrl;
    final isLoading = updateProvider.isLoading;
    final updateAvailable = updateProvider.updateAvailable;
    final hasChecked = updateProvider.remoteInfo != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.system_update_outlined,
                color: AppColors.grey900,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Check update', style: AppTypography.titleLg),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppDecorations.card(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_android_outlined,
                        size: 22,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Installed version',
                              style: AppTypography.titleSm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'v$current',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (updateAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'New',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.green700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const _SectionDivider(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : _checkForUpdates,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 22,
                            color: isLoading
                                ? AppColors.grey400
                                : AppColors.green700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check for updates',
                                  style: AppTypography.titleSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.grey900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _statusSubtitle(
                                    isLoading: isLoading,
                                    updateAvailable: updateAvailable,
                                    hasChecked: hasChecked,
                                    latest: latest,
                                  ),
                                  style: AppTypography.caption.copyWith(
                                    color: updateAvailable
                                        ? AppColors.green700
                                        : AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.green700,
                              ),
                            )
                          else
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: AppColors.grey400,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (updateAvailable && latest != null) ...[
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.download_rounded,
                              size: 20,
                              color: AppColors.green700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Version $latest is available',
                                style: AppTypography.titleSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (notes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            notes,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                        if (storeUrl != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _openStore(storeUrl),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text('Update now'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.green700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusSubtitle({
    required bool isLoading,
    required bool updateAvailable,
    required bool hasChecked,
    required String? latest,
  }) {
    if (isLoading) return 'Checking for updates…';
    if (updateAvailable && latest != null) {
      return 'Version $latest is ready to install';
    }
    if (hasChecked) return 'You are on the latest version';
    return 'Tap to check for a newer version';
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppColors.grey100);
  }
}
