import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/citizen/widgets/citizen_segmented_tabs.dart';

/// Toggle buttons for switching between "New Request" and "My Requests" views.
class RequestActionButtons extends StatelessWidget {
  final bool showMyRequests;
  final VoidCallback onNewRequest;
  final VoidCallback onMyRequests;

  const RequestActionButtons({
    super.key,
    required this.showMyRequests,
    required this.onNewRequest,
    required this.onMyRequests,
  });

  @override
  Widget build(BuildContext context) {
    return CitizenSegmentedTabs<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('New Request'),
          icon: Icon(Icons.add, size: CitizenSegmentedTabs.iconSize),
        ),
        ButtonSegment(
          value: true,
          label: Text('My Requests'),
          icon: Icon(Icons.list_alt_rounded, size: CitizenSegmentedTabs.iconSize),
        ),
      ],
      selected: {showMyRequests},
      onSelectionChanged: (selection) {
        final next = selection.first;
        if (next) {
          onMyRequests();
        } else {
          onNewRequest();
        }
      },
    );
  }
}
