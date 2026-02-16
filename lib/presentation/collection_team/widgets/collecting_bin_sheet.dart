import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import '../models/route_models.dart';

/// Bottom sheet for collecting a bin — report issues, add notes, take photo,
/// and mark as collected.
class CollectingBinSheet extends StatefulWidget {
  final BinData bin;
  final String locationName;

  const CollectingBinSheet({
    super.key,
    required this.bin,
    required this.locationName,
  });

  /// Show the sheet as a modal bottom sheet and return true if collected.
  static Future<bool?> show(
    BuildContext context, {
    required BinData bin,
    required String locationName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollectingBinSheet(bin: bin, locationName: locationName),
    );
  }

  @override
  State<CollectingBinSheet> createState() => _CollectingBinSheetState();
}

class _CollectingBinSheetState extends State<CollectingBinSheet> {
  final Set<String> _selectedIssues = {};
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _issueOptions = [
    'Bin damaged',
    'Access blocked',
    'Overflow/Spillage',
    'Wrong bin type',
    'Contamination',
    'Location issue',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DesignTokens.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                _buildHeader(),
                const SizedBox(height: 16),
                // Bin info card
                _buildBinInfoCard(),
                const SizedBox(height: 16),
                // Report Issues section
                _buildReportIssues(),
                const SizedBox(height: 16),
                // Add Notes section
                _buildAddNotes(),
                const SizedBox(height: 16),
                // Take Photo button
                _buildTakePhotoButton(),
                const SizedBox(height: 16),
                // Mark as Collected button
                _buildCollectButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Collecting Bin',
                style: TextStyle(
                  color: DesignTokens.grey900,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.locationName,
                style: const TextStyle(
                  color: DesignTokens.grey600,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DesignTokens.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: DesignTokens.grey600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bin info card ───────────────────────────────────────────

  Widget _buildBinInfoCard() {
    final isFull = widget.bin.fillStatus == BinFillStatus.full;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: DesignTokens.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Bin ID badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.green700.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: DesignTokens.green700.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  widget.bin.id,
                  style: const TextStyle(
                    color: DesignTokens.green700,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              // Fill status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isFull ? DesignTokens.red500 : DesignTokens.orange600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFull ? 'FULL' : 'HALF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.bin.address,
            style: const TextStyle(
              color: DesignTokens.grey600,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Report Issues ───────────────────────────────────────────

  Widget _buildReportIssues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: DesignTokens.red500),
            SizedBox(width: 8),
            Text(
              'Report Issues (Optional)',
              style: TextStyle(
                color: DesignTokens.grey900,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _issueOptions.map((issue) {
            final isSelected = _selectedIssues.contains(issue);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedIssues.remove(issue);
                  } else {
                    _selectedIssues.add(issue);
                  }
                });
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 56) / 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignTokens.green700.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? DesignTokens.green700
                        : DesignTokens.grey200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  issue,
                  style: TextStyle(
                    color: isSelected
                        ? DesignTokens.green700
                        : DesignTokens.grey700,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Add Notes ───────────────────────────────────────────────

  Widget _buildAddNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 16,
              color: DesignTokens.grey600,
            ),
            SizedBox(width: 8),
            Text(
              'Add Notes (Optional)',
              style: TextStyle(
                color: DesignTokens.grey900,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DesignTokens.grey200),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: DesignTokens.grey900, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Any additional information...',
              hintStyle: TextStyle(color: DesignTokens.grey500, fontSize: 14),
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ── Take Photo button ───────────────────────────────────────

  Widget _buildTakePhotoButton() {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera not available in demo'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.grey700,
          side: const BorderSide(color: DesignTokens.grey200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 16),
            SizedBox(width: 8),
            Text(
              'Take Photo (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mark as Collected button ────────────────────────────────

  Widget _buildCollectButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 20),
            SizedBox(width: 8),
            Text(
              'Mark as Collected',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
