import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Data class returned by [RateOfferDialog].
class RatingResult {
  final int rating;
  final String? feedback;
  const RatingResult(this.rating, this.feedback);
}

/// Dialog that lets the citizen rate a completed collection offer.
class RateOfferDialog extends StatefulWidget {
  const RateOfferDialog({super.key});

  @override
  State<RateOfferDialog> createState() => _RateOfferDialogState();
}

class _RateOfferDialogState extends State<RateOfferDialog> {
  int _rating = 5;
  final TextEditingController _feedback = TextEditingController();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate this collector', style: AppTypography.titleLg),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.amber600,
                    size: 32,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedback,
            maxLines: 3,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Share a few words (optional)',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _feedback.text.trim();
            Navigator.of(
              context,
            ).pop(RatingResult(_rating, text.isEmpty ? null : text));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
