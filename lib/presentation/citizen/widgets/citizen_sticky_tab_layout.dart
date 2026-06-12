import 'package:flutter/material.dart';

import 'citizen_segmented_tabs.dart';

/// Keeps the segmented tab bar fixed while content scrolls underneath.
class CitizenStickyTabLayout extends StatelessWidget {
  const CitizenStickyTabLayout({
    super.key,
    required this.tabBar,
    required this.child,
    this.stickyBar,
    this.onRefresh,
    this.isLoading = false,
  });

  final Widget tabBar;
  final Widget child;
  final Widget? stickyBar;
  final Future<void> Function()? onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Widget scrollContent = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, stickyBar == null ? 16 : 8, 24, 140),
      child: child,
    );

    if (onRefresh != null) {
      scrollContent = RefreshIndicator(
        onRefresh: onRefresh!,
        child: scrollContent,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: CitizenSegmentedTabs.sectionPadding,
          child: tabBar,
        ),
        if (stickyBar != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: stickyBar,
          ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : scrollContent,
        ),
      ],
    );
  }
}
