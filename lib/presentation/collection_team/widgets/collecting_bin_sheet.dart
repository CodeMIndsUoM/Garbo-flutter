import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/route_model.dart';

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
                      color: AppColors.grey300,
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
              Text('Collecting Bin', style: AppTypography.displaySm),
              const SizedBox(height: 4),
              Text(
                widget.locationName,
                style: AppTypography.bodyMd.copyWith(color: AppColors.grey600),
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
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.grey600,
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
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
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
                  color: AppColors.green700.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.green700.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  widget.bin.id,
                  style: AppTypography.captionSm.copyWith(
                    color: AppColors.green700,
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
                  color: isFull ? AppColors.red500 : AppColors.orange600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFull ? 'FULL' : 'HALF',
                  style: AppTypography.labelSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.bin.address,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey600),
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
        Row(
          children: [
            const Icon(Icons.error_outline, size: 16, color: AppColors.red500),
            const SizedBox(width: 8),
            Text(
              'Report Issues (Optional)',
              style: AppTypography.titleSm,
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
                      ? AppColors.green700.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.green700
                        : AppColors.grey200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  issue,
                  style: AppTypography.labelMd.copyWith(
                    color: isSelected
                        ? AppColors.green700
                        : AppColors.grey700,
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
        Row(
          children: [
            const Icon(
              Icons.edit_note_rounded,
              size: 16,
              color: AppColors.grey600,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Notes (Optional)',
              style: AppTypography.titleSm,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: 'Any additional information...',
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey500),
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
          foregroundColor: AppColors.grey700,
          side: const BorderSide(color: AppColors.grey200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 16),
            const SizedBox(width: 8),
            Text(
              'Take Photo (Optional)',
              style: AppTypography.buttonMd.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
          backgroundColor: AppColors.green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mark as Collected',
              style: AppTypography.buttonLg,
            ),
          ],
        ),
      ),
    );
  }
}
