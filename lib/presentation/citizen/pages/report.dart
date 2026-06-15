import 'dart:io';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/core/utils/location_helper.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/pages/pickup_location_picker_page.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/citizen_segmented_tabs.dart';
import 'package:garbo_swms/presentation/citizen/widgets/citizen_sticky_tab_layout.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/citizen/pages/report/report_status_helpers.dart';
import 'package:garbo_swms/presentation/citizen/widgets/citizen_dropdown_field.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';
import 'package:garbo_swms/presentation/shared/widgets/location_map_preview.dart';
import 'package:garbo_swms/presentation/shared/widgets/location_submit_actions.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_search_filter_bar.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_status_filter_sheet.dart';
import 'package:garbo_swms/presentation/shared/widgets/submission_success.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CitizenReportPage extends StatefulWidget {
  const CitizenReportPage({super.key});

  @override
  State<CitizenReportPage> createState() => CitizenReportPageState();
}

class CitizenReportPageState extends State<CitizenReportPage> {
  final ApiService _apiService = ApiService();
  final _descriptionController = TextEditingController();
  final _reportSearchController = TextEditingController();
  final _picker = ImagePicker();

  int currentStep = 1;
  String? selectedIssueType;
  String? selectedUrgency;
  String? selectedWasteType;
  bool showMyReports = false;
  bool _submitting = false;
  bool _loadingReports = false;
  bool _gettingLocation = false;
  String _reportStatusFilter = 'ALL';
  LatLng? _reportLocation;
  File? _photoFile;
  List<Map<String, dynamic>> _reports = [];

  static const _issueTypes = [
    'Overflowing Bin',
    'Illegal Dumping',
    'Missed Collection',
    'Damaged Bin',
    'Other',
  ];
  static const _urgencyLevels = ['Low', 'Normal', 'High', 'Critical'];
  static const _wasteTypes = [
    'General Waste',
    'Recyclables',
    'Organic',
    'Hazardous',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _reportSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _loadingReports = true);
    try {
      final reports = await _apiService.getMyComplaints();
      if (mounted) setState(() => _reports = reports);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load reports')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingReports = false);
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _gettingLocation = true);
    final position = await LocationHelper.getCurrentPositionOrNull(
      onError: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
    );
    if (mounted) {
      setState(() {
        _reportLocation = position == null
            ? null
            : LatLng(position.latitude, position.longitude);
        _gettingLocation = false;
      });
    }
  }

  Future<void> _openLocationPicker() async {
    final selected = await context.pushAppPage<LatLng>(
      PickupLocationPickerPage(
        initialLocation: _reportLocation ?? const LatLng(6.9271, 79.8612),
        appBarTitle: 'Report Location',
        instructions: 'Place the pin where the waste issue is located.',
        confirmLabel: 'Confirm Report Location',
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _reportLocation = selected);
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _submitReport() async {
    if (selectedIssueType == null || selectedUrgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    if (_reportLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required. Enable location services.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      String? imageUrl;
      if (_photoFile != null) {
        imageUrl = await _apiService.uploadComplaintImage(_photoFile!);
      }

      await _apiService.createComplaint({
        'title': selectedIssueType,
        'issueType': selectedIssueType,
        'urgency': selectedUrgency,
        'wasteType': selectedWasteType,
        'description': _descriptionController.text.trim().isEmpty
            ? 'Report submitted via mobile app'
            : _descriptionController.text.trim(),
        'location':
            '${_reportLocation!.latitude.toStringAsFixed(6)}, ${_reportLocation!.longitude.toStringAsFixed(6)}',
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      if (!mounted) return;
      await showSubmissionSuccess(context, message: 'Report submitted');
      if (!mounted) return;
      setState(() {
        currentStep = 1;
        selectedIssueType = null;
        selectedUrgency = null;
        selectedWasteType = null;
        _descriptionController.clear();
        _photoFile = null;
        _reportLocation = null;
        showMyReports = true;
      });
      await _loadReports();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  int get _reportActiveFilterCount {
    var count = 0;
    if (_reportStatusFilter != 'ALL') count++;
    if (_reportSearchController.text.trim().isNotEmpty) count++;
    return count;
  }

  List<Map<String, dynamic>> get _filteredReports {
    final query = _reportSearchController.text.trim().toLowerCase();
    return _reports.where((report) {
      final status = (report['status'] ?? 'PENDING').toString();
      if (_reportStatusFilter != 'ALL' && status != _reportStatusFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        report['title'],
        report['issueType'],
        report['location'],
        report['id'],
        status,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  Widget _buildReportsFilterBar() {
    return CitizenSearchFilterBar(
      searchController: _reportSearchController,
      hintText: 'Search reports, locations, #id',
      onChanged: () => setState(() {}),
      onFilterTap: () => showCitizenStatusFilterSheet(
        context: context,
        currentStatus: _reportStatusFilter,
        onApply: (status) => setState(() => _reportStatusFilter = status),
        options: const [
          ('ALL', 'All'),
          ('PENDING', 'Pending'),
          ('APPROVED', 'Approved'),
          ('REJECTED', 'Rejected'),
          ('RESOLVED', 'Resolved'),
        ],
      ),
      activeFilterCount: _reportActiveFilterCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CitizenHeader(name: 'Reports'),
          Expanded(
            child: CitizenStickyTabLayout(
              tabBar: buildActionButtons(theme),
              onRefresh: _loadReports,
              isLoading: _loadingReports && _reports.isEmpty && showMyReports,
              stickyBar: showMyReports ? _buildReportsFilterBar() : null,
              child: showMyReports ? buildReportsList(theme) : buildReportForm(theme),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 1),
    );
  }

  Widget buildActionButtons(ThemeData theme) {
    return CitizenSegmentedTabs<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('New Report'),
          icon: Icon(Icons.note_add_outlined, size: CitizenSegmentedTabs.iconSize),
        ),
        ButtonSegment(
          value: true,
          label: Text('My Reports'),
          icon: Icon(Icons.list_alt_rounded, size: CitizenSegmentedTabs.iconSize),
        ),
      ],
      selected: {showMyReports},
      onSelectionChanged: (selection) {
        final next = selection.first;
        setState(() => showMyReports = next);
        if (next) _loadReports();
      },
    );
  }

  Widget buildReportForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report Waste Issue', style: AppTypography.titleLg),
        const SizedBox(height: 8),
        Text('Step $currentStep of 3', style: AppTypography.bodySm),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: currentStep / 3),
        const SizedBox(height: 24),
        if (currentStep == 1) ...[
          _buildDropdownField(
            label: 'Issue Type',
            options: _issueTypes,
            value: selectedIssueType,
            onChanged: (v) => setState(() => selectedIssueType = v),
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Urgency',
            options: _urgencyLevels,
            value: selectedUrgency,
            onChanged: (v) => setState(() => selectedUrgency = v),
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Waste Type',
            options: _wasteTypes,
            value: selectedWasteType,
            onChanged: (v) => setState(() => selectedWasteType = v),
            optional: true,
          ),
        ] else if (currentStep == 2) ...[
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the issue...',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(_photoFile == null ? 'Add Photo (Optional)' : 'Photo Selected'),
          ),
        ] else ...[
          Text(
            'Report location *',
            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          LocationSubmitActions(
            onChooseOnMap: _openLocationPicker,
            onUseCurrentLocation: _captureLocation,
            resolvingLocation: _gettingLocation,
          ),
          if (_reportLocation != null) ...[
            const SizedBox(height: 16),
            LocationMapPreview(
              location: _reportLocation!,
              onTap: _openLocationPicker,
            ),
            const SizedBox(height: 8),
            Text(
              'Lat ${_reportLocation!.latitude.toStringAsFixed(5)}, '
              'Lng ${_reportLocation!.longitude.toStringAsFixed(5)}',
              style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'Choose on map or use your current location.',
              style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
            ),
          ],
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting
                ? null
                : () {
                    if (currentStep < 3) {
                      if (currentStep == 1 &&
                          (selectedIssueType == null || selectedUrgency == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select issue type and urgency')),
                        );
                        return;
                      }
                      setState(() => currentStep++);
                    } else {
                      _submitReport();
                    }
                  },
            child: Text(
              currentStep < 3
                  ? 'Next'
                  : (_submitting ? 'Submitting...' : 'Submit Report'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool optional = false,
  }) {
    return CitizenDropdownField(
      label: label,
      options: options,
      value: value,
      onChanged: onChanged,
      optional: optional,
    );
  }

  Widget buildReportsList(ThemeData theme) {
    if (_loadingReports) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No reports yet')),
      );
    }

    if (_filteredReports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No matching reports. Try changing your filters.')),
      );
    }

    return Column(
      children: _filteredReports.map((report) {
        final title = (report['title'] ?? report['issueType'] ?? 'Report').toString();
        final location = (report['location'] ?? '-').toString();
        final status = (report['status'] ?? 'PENDING').toString();
        final createdAt = (report['createdAt'] ?? '').toString();
        final statusColors = complaintStatusStyle(status);

        return CitizenSurfaceCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.report_outlined, color: statusColors.iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSm),
                    const SizedBox(height: 4),
                    Text(location, style: AppTypography.bodySm),
                    if (createdAt.isNotEmpty)
                      Text(
                        createdAt.split('T').first,
                        style: AppTypography.bodySm,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColors.tagBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: AppTypography.captionSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColors.tagText,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
