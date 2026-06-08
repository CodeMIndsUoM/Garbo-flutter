import 'package:flutter/material.dart';

/// Shared segmented tab bar styling for citizen Report, Events, and Requests.
class CitizenSegmentedTabs<T> extends StatelessWidget {
  const CitizenSegmentedTabs({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  static const double iconSize = 20;

  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(24, 16, 24, 16);

  static ButtonStyle get tabStyle => ButtonStyle(
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        minimumSize: WidgetStateProperty.all(const Size(0, 48)),
      );

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      showSelectedIcon: false,
      style: tabStyle,
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
    );
  }
}
