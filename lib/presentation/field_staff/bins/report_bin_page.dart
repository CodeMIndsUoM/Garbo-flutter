import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/core/utils/location_helper.dart';
import 'package:garbo_swms/presentation/shared/widgets/location_submit_actions.dart';
import 'package:garbo_swms/presentation/shared/widgets/submission_success.dart';
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

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Position? _reportLocation;
  bool _gettingLocation = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.green700),
                title: Text('Take a Photo', style: AppTypography.bodyMd),
                onTap: () {
                  Navigator.pop(context);
                  _processImagePicker(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.green700),
                title: Text('Choose from Gallery', style: AppTypography.bodyMd),
                onTap: () {
                  Navigator.pop(context);
                  _processImagePicker(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processImagePicker(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to pick image: $e');
      }
    }
  }

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

    // Use captured location, or try GPS at submit time as fallback.
    final position = _reportLocation ?? await _tryGetCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required. Tap "Current location" first.'),
        ),
      );
      return;
    }
    final double reportLat = position.latitude;
    final double reportLng = position.longitude;

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
        binId: widget.bin.id,
        reportData: payload,
        photoPath: _selectedImage?.path,
      );

      if (mounted) {
        if (success) {
          await _updateDayStreak();
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          await showSubmissionSuccess(context, message: 'Report submitted');
          if (!mounted) return;
          Navigator.of(context).pop(true);
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

  Future<void> _captureLocation() async {
    setState(() => _gettingLocation = true);
    final position = await LocationHelper.getCurrentPositionOrNull(
      onError: _showError,
    );
    if (!mounted) return;
    setState(() {
      _reportLocation = position;
      _gettingLocation = false;
    });
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

  // DEVELOPER NOTE: Main form layout for reporting bin status.
  // Coordinates the fill-level option buttons, issues text field, photo attach selector, and submission actions.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Report Bin Status', style: AppTypography.h3),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.grey900),
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
                  // Bin code subtitle
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
                        widget.bin.displayCode,
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
                    bgColor: AppColors.amberSurface,
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
                    style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
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
                        borderSide: BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey200),
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

                  _buildSectionTitle('Report Location *'),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _reportLocation != null
                          ? Icons.location_on
                          : Icons.location_off,
                      color: AppColors.green700,
                    ),
                    title: Text(
                      _reportLocation != null
                          ? 'Location captured (${_reportLocation!.latitude.toStringAsFixed(4)}, ${_reportLocation!.longitude.toStringAsFixed(4)})'
                          : 'Location required',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    subtitle: Text(
                      'Use your current GPS position for this report',
                      style: AppTypography.bodySm,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: LocationActionButton(
                      onPressed: _captureLocation,
                      loading: _gettingLocation,
                      label: _gettingLocation
                          ? 'Getting location...'
                          : 'Current location',
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
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red500,
                        side: const BorderSide(color: AppColors.red500, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.red500,
                          fontWeight: FontWeight.w600,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: isSelected
            ? BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 2),
              )
            : AppDecorations.card(),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : color,
              size: 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.titleLg.copyWith(
                      color: isSelected ? AppColors.grey900 : AppColors.grey700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // DEVELOPER NOTE: Styling configuration for the optional photo attachment container (width, height, background color, borders, and icons).
  Widget _buildPhotoPlaceholder() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: AppDecorations.card(
          color: _selectedImage == null ? AppColors.surface : AppColors.grey100,
        ).copyWith(
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 36,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take Photo',
                    style: AppTypography.titleMd.copyWith(color: AppColors.grey700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Document damage or issues',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.grey700,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
