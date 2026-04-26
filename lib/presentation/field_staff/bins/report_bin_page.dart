import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportBinPage extends StatefulWidget {
  final BinModel bin;
  final String empId;

  const ReportBinPage({super.key, required this.bin, required this.empId});

  @override
  State<ReportBinPage> createState() => _ReportBinPageState();
}

class _ReportBinPageState extends State<ReportBinPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _notesController = TextEditingController();

  // Default to notChecked or null, but UI requires selection.
  // Let's assume user must select one.
  BinStatus? _selectedStatus; // null means none selected
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fill level.')),
      );
      return;
    }

    // TODO: Re-enable GPS requirement for production.
    // Currently using a default location as fallback so the flow works on
    // simulators without location services.
    final position = await _tryGetCurrentPosition();
    final double reportLat = position?.latitude ?? 6.9271;
    final double reportLng = position?.longitude ?? 79.8612;

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        "status": _statusToString(_selectedStatus!),
        "fillLevel": _statusToFillLevel(_selectedStatus!),
        "notes": _notesController.text,
        "latitude": reportLat,
        "longitude": reportLng,
      };

      final success = await _apiService.reportBinStatus(
        widget.empId,
        widget.bin.id,
        payload,
      );

      if (mounted) {
        if (success) {
          await _updateDayStreak();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report submitted for ${widget.bin.id}'),
              backgroundColor: AppColors.green700,
            ),
          );
          Navigator.of(
            context,
          ).pop(true); // Return true to indicate refresh needed
        } else {
          _showError('Failed to submit report. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red500),
    );
  }

  Future<Position?> _tryGetCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateDayStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDateString = prefs.getString('field_staff_last_report_date');
    final currentStreak = prefs.getInt('field_staff_day_streak') ?? 0;

    int nextStreak;
    if (lastDateString == null || lastDateString.isEmpty) {
      nextStreak = 1;
    } else {
      DateTime? lastDate;
      try {
        lastDate = DateTime.parse(lastDateString);
      } catch (_) {
        lastDate = null;
      }

      if (lastDate == null) {
        nextStreak = 1;
      } else {
        final normalizedLast = DateTime(
          lastDate.year,
          lastDate.month,
          lastDate.day,
        );
        final dayDiff = today.difference(normalizedLast).inDays;

        if (dayDiff <= 0) {
          nextStreak = currentStreak > 0 ? currentStreak : 1;
        } else if (dayDiff == 1) {
          nextStreak = currentStreak + 1;
        } else {
          nextStreak = 1;
        }
      }
    }

    await prefs.setInt('field_staff_day_streak', nextStreak);
    await prefs.setString(
      'field_staff_last_report_date',
      today.toIso8601String(),
    );
  }

  String _statusToString(BinStatus status) {
    switch (status) {
      case BinStatus.empty:
        return 'empty';
      case BinStatus.half:
        return 'half';
      case BinStatus.full:
        return 'full';
      default:
        return 'notChecked';
    }
  }

  int _statusToFillLevel(BinStatus status) {
    switch (status) {
      case BinStatus.empty:
        return 0;
      case BinStatus.half:
        return 50;
      case BinStatus.full:
        return 100;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Report Bin Status', style: AppTypography.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Subtitle
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.bin.location,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Select Fill Level
                  _buildSectionTitle('Select Fill Level *'),
                  const SizedBox(height: 16),
                  _buildStatusOption(
                    status: BinStatus.empty,
                    label: 'Empty',
                    description: 'Bin is empty or near empty',
                    color: AppColors.green700,
                    bgColor: AppColors.emerald50,
                    icon: Icons.sentiment_satisfied_alt,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusOption(
                    status: BinStatus.half,
                    label: 'Half Full',
                    description: 'Bin is about halfway filled',
                    color: AppColors.amber600,
                    bgColor: AppColors.orange50,
                    icon: Icons.sentiment_neutral,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusOption(
                    status: BinStatus.full,
                    label: 'Full',
                    description: 'Bin is full or overflowing',
                    color: AppColors.red500,
                    bgColor: AppColors.red50,
                    icon: Icons.sentiment_very_dissatisfied,
                  ),

                  const SizedBox(height: 32),

                  // Issue Notes
                  _buildSectionTitle('Issue Notes (Optional)'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Add notes about damage, overflow, or other issues...',
                      hintStyle: AppTypography.bodyMd.copyWith(
                        color: AppColors.grey500,
                      ),
                      filled: true,
                      fillColor: AppColors.grey50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.green700,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Attach Photo
                  _buildSectionTitle('Attach Photo (Optional)'),
                  const SizedBox(height: 12),
                  _buildPhotoPlaceholder(),

                  const SizedBox(height: 40),

                  // Submit Button (Added for better UX)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit Report',
                        style: AppTypography.titleLg.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors
                            .red100, // Light red background like screenshot
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.red500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.titleLg);
  }

  Widget _buildStatusOption({
    required BinStatus status,
    required String label,
    required String description,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = status);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleLg),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 40,
            color: AppColors.blue600,
          ),
          const SizedBox(height: 12),
          Text('Take Photo', style: AppTypography.titleLg),
          const SizedBox(height: 4),
          Text(
            'Document damage or issues',
            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
