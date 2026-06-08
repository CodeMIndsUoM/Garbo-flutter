import 'package:flutter/material.dart';

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
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('New Request'),
          icon: Icon(Icons.add, size: 18),
        ),
        ButtonSegment(
          value: true,
          label: Text('My Requests'),
          icon: Icon(Icons.list_alt_rounded, size: 18),
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
