import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onNewRequest,
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'New Request',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: !showMyRequests
                  ? AppColors.emerald600
                  : Colors.white,
              foregroundColor: !showMyRequests
                  ? Colors.white
                  : AppColors.emerald600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: showMyRequests
                  ? const BorderSide(color: AppColors.emerald600, width: 1.5)
                  : BorderSide.none,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onMyRequests,
            icon: const Icon(Icons.list_alt_rounded, size: 18),
            label: const Text(
              'My Requests',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: showMyRequests
                  ? AppColors.emerald600
                  : Colors.white,
              foregroundColor: showMyRequests
                  ? Colors.white
                  : AppColors.emerald600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: !showMyRequests
                  ? const BorderSide(color: AppColors.emerald600, width: 1.5)
                  : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
