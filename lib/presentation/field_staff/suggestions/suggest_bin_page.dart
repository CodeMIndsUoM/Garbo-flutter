import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/core/utils/location_helper.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/pages/pickup_location_picker_page.dart';
import 'package:garbo_swms/presentation/field_staff/suggestions/models/bin_suggestion_model.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';
import 'package:garbo_swms/presentation/shared/widgets/location_submit_actions.dart';
import 'package:garbo_swms/presentation/shared/widgets/submission_success.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

enum _SuggestView { suggest, mySuggestions }

class SuggestBinPage extends StatefulWidget {
  const SuggestBinPage({super.key});

  @override
  State<SuggestBinPage> createState() => _SuggestBinPageState();
}

class _SuggestBinPageState extends State<SuggestBinPage> {
  final ApiService _apiService = ApiService();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  _SuggestView _view = _SuggestView.suggest;
  List<BinSuggestionModel> _suggestions = [];
  bool _loading = false;
  bool _submitting = false;
  bool _resolvingLocation = false;
  String _category = 'general';
  LatLng? _location;
  File? _selectedImage;
  bool _didAttachRealtimeListener = false;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>? _socketSubscription;

  static const _categories = [
    'general',
    'recyclable',
    'organic',
    'hazardous',
  ];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAttachRealtimeListener) return;
    _didAttachRealtimeListener = true;
    _attachRealtimeRefresh(context.read<WebSocketProvider>());
  }

  void _attachRealtimeRefresh(WebSocketProvider provider) {
    _socketSubscription?.cancel();
    _socketSubscription = provider.messageStream.listen((message) {
      if (message.type == 'BIN_SUGGESTION_UPDATED') {
        _loadSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _loading = true);
    try {
      final items = await _apiService.getMyBinSuggestions();
      if (mounted) {
        setState(() => _suggestions = items);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load suggestions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? get _locationLabel {
    if (_location == null) return null;
    return '${_location!.latitude.toStringAsFixed(5)}, '
        '${_location!.longitude.toStringAsFixed(5)}';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _chooseOnMap() async {
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => PickupLocationPickerPage(
          initialLocation: _location ?? const LatLng(6.7952, 79.8957),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _location = selected);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _resolvingLocation = true);
    try {
      final position = await LocationHelper.getCurrentPositionOrNull(
        onError: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
      );
      if (!mounted || position == null) return;
      setState(() => _location = LatLng(position.latitude, position.longitude));
    } finally {
      if (mounted) {
        setState(() => _resolvingLocation = false);
      }
    }
  }

  Future<void> _submitSuggestion() async {
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a location first.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _apiService.uploadBinSuggestionImage(_selectedImage!);
      }

      await _apiService.createBinSuggestion({
        'category': _category,
        'notes': _notesController.text.trim(),
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
        'location': '${_location!.latitude},${_location!.longitude}',
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      if (!mounted) return;
      await showSubmissionSuccess(
        context,
        message: 'Suggestion submitted. Your council admin will review it.',
      );

      setState(() {
        _notesController.clear();
        _location = null;
        _selectedImage = null;
        _category = 'general';
        _view = _SuggestView.mySuggestions;
      });
      await _loadSuggestions();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Color _statusColor(BinSuggestionModel item) {
    if (item.isPending) return AppColors.amber600;
    if ((item.status ?? '').toUpperCase() == 'REJECTED') {
      return AppColors.red500;
    }
    return AppColors.green700;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadSuggestions,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
        children: [
          SegmentedButton<_SuggestView>(
            segments: const [
              ButtonSegment(
                value: _SuggestView.suggest,
                label: Text('Suggest'),
                icon: Icon(Icons.add_location_alt_outlined),
              ),
              ButtonSegment(
                value: _SuggestView.mySuggestions,
                label: Text('My Suggestions'),
                icon: Icon(Icons.list_alt_rounded),
              ),
            ],
            selected: {_view},
            onSelectionChanged: (selection) {
              setState(() => _view = selection.first);
            },
          ),
          const SizedBox(height: 20),
          if (_view == _SuggestView.suggest) _buildSuggestForm(),
          if (_view == _SuggestView.mySuggestions) _buildMySuggestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggest a New Bin', style: AppTypography.titleLg),
        const SizedBox(height: 8),
        Text(
          'Propose a new bin location for your council admin to review.',
          style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 20),
        Text('Category', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
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
          ),
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c[0].toUpperCase() + c.substring(1)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _category = value);
          },
        ),
        const SizedBox(height: 16),
        Text('Notes (optional)', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Why is a bin needed here?',
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
          ),
        ),
        const SizedBox(height: 16),
        Text('Location', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        if (_locationLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_locationLabel!, style: AppTypography.bodySm),
          ),
        LocationSubmitActions(
          onChooseOnMap: _chooseOnMap,
          onUseCurrentLocation: _useCurrentLocation,
          resolvingLocation: _resolvingLocation,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showImagePickerSheet(),
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(_selectedImage == null ? 'Add photo (optional)' : 'Change photo'),
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_selectedImage!, height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submitSuggestion,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green700,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit suggestion'),
          ),
        ),
      ],
    );
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.green700),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.green700),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMySuggestions() {
    if (_loading && _suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No suggestions yet. Use the Suggest tab to propose a new bin.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Suggestions', style: AppTypography.titleLg),
        const SizedBox(height: 16),
        ..._suggestions.map(_buildSuggestionCard),
      ],
    );
  }

  Widget _buildSuggestionCard(BinSuggestionModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.category?.isNotEmpty == true
                      ? item.category![0].toUpperCase() + item.category!.substring(1)
                      : 'Bin suggestion #${item.id}',
                  style: AppTypography.titleSm,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(item).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.displayStatus,
                  style: AppTypography.labelSm.copyWith(
                    color: _statusColor(item),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (item.location != null) ...[
            const SizedBox(height: 8),
            Text(item.location!, style: AppTypography.bodySm.copyWith(color: AppColors.grey600)),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.notes!, style: AppTypography.bodySm),
          ],
          if (item.resolutionNotes != null && item.resolutionNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.resolutionNotes!,
              style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
            ),
          ],
          if (item.createdBinId != null) ...[
            const SizedBox(height: 8),
            Text(
              'Bin created (#${item.createdBinId})',
              style: AppTypography.labelSm.copyWith(color: AppColors.green700),
            ),
          ],
          if (item.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              item.createdAt!.toLocal().toString().split('.').first,
              style: AppTypography.labelSm.copyWith(color: AppColors.grey500),
            ),
          ],
        ],
      ),
    );
  }
}
