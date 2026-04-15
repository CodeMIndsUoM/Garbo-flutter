import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
// Just checking if we need imports

class BinDetailsOverlay extends StatelessWidget {
  final BinModel bin;

  const BinDetailsOverlay({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Badges & Close Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          bin.id,
                          style: const TextStyle(
                            color: Color(0xFF495565),
                            fontSize: 11,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: ShapeDecoration(
                          color: _getBadgeBgColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          bin.status.label.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusTextColor(),
                            fontSize: 11,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFF101727),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title & Subtitle
              Text(
                bin.location,
                style: const TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 20,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bin.address,
                style: const TextStyle(
                  color: Color(0xFF495565),
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              
              // Status Large Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: ShapeDecoration(
                  color: _getCardBgColor(),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.27, color: _getCardBorderColor()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getCardTextColor(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _getStatusIcon(),
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bin.status.label,
                      style: TextStyle(
                        color: _getCardTextColor(),
                        fontSize: 24,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Details List
              _buildDetailRow('Type', bin.category.label),
              const Divider(color: Color(0xFFF2F4F6), height: 32),
              _buildDetailRow('Last Checked', bin.timeAgo),
              const Divider(color: Color(0xFFF2F4F6), height: 32),
              _buildDetailRow('Assigned To', 'John Smith'),
              const SizedBox(height: 32),

              // Bottom View Map Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1.27, color: Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF354152),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'View on Map',
                      style: TextStyle(
                        color: Color(0xFF354152),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF495565),
            fontSize: 13,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF101727),
            fontSize: 13,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // --- Theme Helpers based on Status ---

  Color _getBadgeBgColor() {
    switch (bin.status) {
      case BinStatus.notChecked:
        return const Color(0xFFF3F4F6); // Grey
      case BinStatus.full:
        return const Color(0xFFFFE2E2); // Light Red
      case BinStatus.half:
        return const Color(0xFFFFF6D8); // Light Orange/Yellow
      case BinStatus.empty:
        return const Color(0xFFE2FBE9); // Light Green
    }
  }

  Color _getStatusTextColor() {
    switch (bin.status) {
      case BinStatus.notChecked:
        return const Color(0xFF495565); // Dark Grey
      case BinStatus.full:
        return const Color(0xFFC10007); // Dark Red
      case BinStatus.half:
        return const Color(0xFFCC7A00); // Dark Orange
      case BinStatus.empty:
        return const Color(0xFF007A2E); // Dark Green
    }
  }

  Color _getCardBgColor() {
    switch (bin.status) {
      case BinStatus.notChecked:
        return const Color(0xFFF9FAFB);
      case BinStatus.full:
        return const Color(0xFFFFE2E2);
      case BinStatus.half:
        return const Color(0xFFFFF8E1);
      case BinStatus.empty:
        return const Color(0xFFE8FDF0);
    }
  }

  Color _getCardBorderColor() {
    switch (bin.status) {
      case BinStatus.notChecked:
        return const Color(0xFFE5E7EB);
      case BinStatus.full:
        return const Color(0xFFFFC9C9);
      case BinStatus.half:
        return const Color(0xFFFFECAA);
      case BinStatus.empty:
        return const Color(0xFFB0F1C3);
    }
  }

  Color _getCardTextColor() {
    switch (bin.status) {
      case BinStatus.notChecked:
        return const Color(0xFF6B7280);
      case BinStatus.full:
        return const Color(0xFFE7000A);
      case BinStatus.half:
        return const Color(0xFFE2A000);
      case BinStatus.empty:
        return const Color(0xFF00A63E);
    }
  }

  IconData _getStatusIcon() {
    switch (bin.status) {
      case BinStatus.notChecked:
        return Icons.help_outline;
      case BinStatus.full:
        return Icons.sentiment_very_dissatisfied;
      case BinStatus.half:
        return Icons.sentiment_neutral;
      case BinStatus.empty:
        return Icons.sentiment_satisfied_alt;
    }
  }
}
