import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/pages/pickup_location_picker_page.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CitizenRequestPage extends StatefulWidget {
  const CitizenRequestPage({super.key});

  @override
  State<CitizenRequestPage> createState() => CitizenRequestPageState();
}

class CitizenRequestPageState extends State<CitizenRequestPage>
    with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int currentStep = 1;
  String? selectedWasteType;
  String? selectedQuantity;
  DateTime? selectedPickupDate;
  String? selectedTimeSlot;
  LatLng? _pickupLocation;
  bool showMyRequests = false;
  bool _submitting = false;
  bool _loadingRequests = false;
  String? _citizenId;
  String? _requestPhotoPath;
  List<CollectionRequestModel> _requests = const [];
  Timer? _pollTimer;
  bool _backgroundRefreshInFlight = false;
  static const Duration _pollInterval = Duration(seconds: 15);

  String _statusFilter = 'ALL';
  String _wasteTypeFilter = 'ALL';
  final TextEditingController _requestSearchController =
      TextEditingController();

  static const List<(String, String)> _statusFilterOptions = [
    ('ALL', 'All'),
    ('OPEN', 'Open'),
    ('ASSIGNED', 'Assigned'),
    ('COMPLETED', 'Completed'),
    ('CONFIRMED', 'Confirmed'),
    ('CANCELLED', 'Cancelled'),
  ];

  static const List<String> _wasteTypeItems = [
    'Plastic',
    'Glass',
    'Metal',
    'E-Waste',
    'Paper',
    'Organic',
    'Textile',
    'Mixed',
  ];

  static const List<String> _quantityItems = [
    'Small (1-2 bags/items)',
    'Medium (3-5 bags/items)',
    'Large (6-10 bags/items)',
    'Extra Large (10+ bags/items)',
  ];

  static const List<String> _timeSlotItems = [
    'Morning (8AM-12PM)',
    'Afternoon (12PM-4PM)',
    'Evening (4PM-7PM)',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    _startPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSilently();
      _startPolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refreshSilently());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _refreshSilently() async {
    if (_backgroundRefreshInFlight || !mounted) return;
    final citizenId = _citizenId;
    if (citizenId == null || citizenId.isEmpty) return;
    _backgroundRefreshInFlight = true;
    try {
      final requests = await _apiService.getCitizenCollectionRequests(
        citizenId,
      );
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (_) {
      // Silent — keep last good list; the next tick will retry.
    } finally {
      _backgroundRefreshInFlight = false;
    }
  }

  Future<void> _bootstrap() async {
    final citizenId = await _apiService.getStoredEmpId();
    if (!mounted) return;
    setState(() => _citizenId = citizenId);
    await _loadRequests();
  }

  Future<void> _loadRequests() async {
    final citizenId = _citizenId;
    if (citizenId == null || citizenId.isEmpty) {
      return;
    }

    setState(() => _loadingRequests = true);
    try {
      final requests = await _apiService.getCitizenCollectionRequests(
        citizenId,
      );
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not load your requests: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loadingRequests = false);
      }
    }
  }

  Future<void> _submitRequest() async {
    final citizenId = _citizenId;
    if (citizenId == null || citizenId.isEmpty) {
      _showSnackBar('Please log in again to continue.', isError: true);
      return;
    }

    final validationError = _validateForm();
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      String? requestPhotoUrl;
      if (_requestPhotoPath != null) {
        requestPhotoUrl = await _apiService.uploadCitizenRequestPhoto(
          citizenId: citizenId,
          photoPath: _requestPhotoPath!,
        );
      }

      await _apiService.createCollectionRequest(
        citizenId: citizenId,
        payload: {
          'wasteType': _mapWasteType(selectedWasteType!),
          'quantityLabel': selectedQuantity,
          'quantityKgEstimate': null,
          'addressLine': _addressController.text.trim(),
          'latitude': _pickupLocation!.latitude,
          'longitude': _pickupLocation!.longitude,
          'preferredDate': _formatDate(selectedPickupDate!),
          'preferredSlot': _mapTimeSlot(selectedTimeSlot!),
          'contactPhone': _phoneController.text.trim(),
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          'photoUrl': requestPhotoUrl,
        },
      );
      if (!mounted) return;
      _resetForm();
      setState(() {
        showMyRequests = true;
      });
      await _loadRequests();
      _showSnackBar('Request submitted successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not submit request: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _validateForm() {
    if (selectedWasteType == null) return 'Please select a waste type.';
    if (selectedQuantity == null) return 'Please select an estimated quantity.';
    if (selectedPickupDate == null) return 'Please select a pickup date.';
    if (selectedTimeSlot == null) return 'Please select a time slot.';
    if (_pickupLocation == null) {
      return 'Please choose a pickup location on the map.';
    }
    if (_addressController.text.trim().isEmpty) {
      return 'Please enter the pickup address.';
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Please enter a contact phone number.';
    }
    return null;
  }

  void _resetForm() {
    setState(() {
      currentStep = 1;
      selectedWasteType = null;
      selectedQuantity = null;
      selectedPickupDate = null;
      selectedTimeSlot = null;
      _pickupLocation = null;
      _requestPhotoPath = null;
    });
    _addressController.clear();
    _phoneController.clear();
    _notesController.clear();
  }

  Future<void> _pickRequestPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (picked == null || !mounted) return;
    setState(() => _requestPhotoPath = picked.path);
  }

  Future<void> _openPickupLocationPicker() async {
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(
        builder: (_) => PickupLocationPickerPage(
          initialLocation: _pickupLocation ?? const LatLng(6.9271, 79.8612),
          initialAddress: _addressController.text.trim(),
        ),
      ),
    );

    if (selected == null || !mounted) return;
    setState(() => _pickupLocation = selected);
  }

  Future<void> _openRequestDetail(CollectionRequestModel request) async {
    try {
      final detail = await _apiService.getCollectionRequestDetail(request.id);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetCtx) => _RequestOffersSheet(
          request: detail,
          onAccept: (offer) => _handleOfferAction(detail.id, offer.id, true),
          onReject: (offer) => _handleOfferAction(detail.id, offer.id, false),
          onConfirm: (offer) => _handleConfirmOffer(sheetCtx, detail.id, offer),
        ),
      );
      unawaited(_loadRequests());
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not load request offers: $e', isError: true);
    }
  }

  void _patchRequestStatus(
    int requestId, {
    String? status,
    int? acceptedOfferId,
    int? offersCount,
  }) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    final updated = _requests[index].copyWith(
      status: status,
      acceptedOfferId: acceptedOfferId,
      offersCount: offersCount,
    );
    setState(() {
      _requests = [
        ..._requests.sublist(0, index),
        updated,
        ..._requests.sublist(index + 1),
      ];
    });
  }

  Future<void> _handleConfirmOffer(
    BuildContext sheetCtx,
    int requestId,
    CollectionOfferModel offer,
  ) async {
    final result = await showDialog<_RatingResult>(
      context: sheetCtx,
      builder: (_) => const _RateOfferDialog(),
    );
    if (result == null) return;
    try {
      await _apiService.confirmOffer(
        offerId: offer.id,
        rating: result.rating,
        feedback: result.feedback,
      );
      if (!mounted) return;
      Navigator.of(sheetCtx).pop();
      _patchRequestStatus(requestId, status: 'CONFIRMED');
      _showSnackBar('Thanks! Your rating was submitted.');
      unawaited(_loadRequests());
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not submit rating: $e', isError: true);
    }
  }

  Future<void> _handleOfferAction(
    int requestId,
    int offerId,
    bool accept,
  ) async {
    try {
      if (accept) {
        await _apiService.acceptOffer(offerId);
      } else {
        await _apiService.rejectOffer(offerId);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      if (accept) {
        _patchRequestStatus(
          requestId,
          status: 'ASSIGNED',
          acceptedOfferId: offerId,
        );
      } else {
        final current = _requests.firstWhere(
          (r) => r.id == requestId,
          orElse: () => _requests.first,
        );
        _patchRequestStatus(
          requestId,
          offersCount: (current.offersCount - 1).clamp(0, 1 << 30),
        );
      }
      _showSnackBar(
        accept
            ? 'Offer accepted successfully.'
            : 'Offer rejected successfully.',
      );
      unawaited(_loadRequests());
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not update offer: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : AppColors.emerald600,
      ),
    );
  }

  String _mapWasteType(String value) {
    switch (value) {
      case 'Plastic':
        return 'PLASTIC';
      case 'Glass':
        return 'GLASS';
      case 'Metal':
        return 'METAL';
      case 'E-Waste':
        return 'E_WASTE';
      case 'Paper':
        return 'PAPER';
      case 'Organic':
        return 'ORGANIC';
      case 'Textile':
        return 'TEXTILE';
      default:
        return 'MIXED';
    }
  }

  String _mapTimeSlot(String value) {
    if (value.startsWith('Morning')) return 'MORNING';
    if (value.startsWith('Afternoon')) return 'AFTERNOON';
    return 'EVENING';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  IconData _iconForWasteType(String wasteType) {
    switch (wasteType) {
      case 'E_WASTE':
        return Icons.electrical_services_rounded;
      case 'METAL':
        return Icons.precision_manufacturing_outlined;
      case 'ORGANIC':
        return Icons.eco_outlined;
      case 'PAPER':
        return Icons.description_outlined;
      case 'TEXTILE':
        return Icons.checkroom_outlined;
      case 'GLASS':
        return Icons.wine_bar_outlined;
      default:
        return Icons.delete_outline_rounded;
    }
  }

  ({Color bg, Color text, String label}) _statusStyle(String status) {
    switch (status) {
      case 'OPEN':
        return (
          bg: AppColors.orange200,
          text: AppColors.orange600,
          label: 'open',
        );
      case 'ASSIGNED':
        return (
          bg: AppColors.blue200,
          text: AppColors.blue600,
          label: 'assigned',
        );
      case 'COMPLETED':
      case 'CONFIRMED':
        return (
          bg: AppColors.emerald200,
          text: AppColors.emerald900,
          label: status.toLowerCase(),
        );
      case 'CANCELLED':
        return (
          bg: AppColors.grey200,
          text: AppColors.grey700,
          label: 'cancelled',
        );
      default:
        return (
          bg: AppColors.grey200,
          text: AppColors.grey700,
          label: status.toLowerCase(),
        );
    }
  }

  String _requestSubtitle(CollectionRequestModel request) {
    if (request.status == 'OPEN' && request.offersCount > 0) {
      return '${request.offersCount} offer${request.offersCount == 1 ? '' : 's'} available';
    }
    if (request.status == 'ASSIGNED') {
      return 'Collector selected';
    }
    if (request.status == 'CONFIRMED') {
      return 'Collection confirmed';
    }
    return request.addressLine;
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _requestSearchController.dispose();
    super.dispose();
  }

  List<String> get _availableWasteTypesForFilter {
    final types = _requests.map((r) => r.wasteType).toSet().toList();
    types.sort();
    return types;
  }

  List<CollectionRequestModel> get _filteredRequests {
    final query = _requestSearchController.text.trim().toLowerCase();
    return _requests.where((r) {
      if (_statusFilter != 'ALL' && r.status != _statusFilter) return false;
      if (_wasteTypeFilter != 'ALL' && r.wasteType != _wasteTypeFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack = [
          r.wasteType,
          r.addressLine,
          '#${r.id}',
          r.quantityLabel,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList(growable: false);
  }

  int get _activeFilterCount {
    var n = 0;
    if (_statusFilter != 'ALL') n++;
    if (_wasteTypeFilter != 'ALL') n++;
    if (_requestSearchController.text.trim().isNotEmpty) n++;
    return n;
  }

  Widget _buildRequestsFilterBar() {
    final activeCount = _activeFilterCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _requestSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search requests, addresses, #id',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _requestSearchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _requestSearchController.clear();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.emerald600,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildFilterIconButton(activeCount),
          ],
        ),
        if (activeCount > 0) ...[
          const SizedBox(height: 10),
          _buildActiveFilterRail(),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFilterIconButton(int activeCount) {
    final hasFilters = activeCount > 0;
    return Material(
      color: hasFilters ? AppColors.emerald600 : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _openRequestsFilterSheet,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasFilters ? AppColors.emerald600 : AppColors.grey300,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.tune_rounded,
                  color: hasFilters ? Colors.white : AppColors.grey700,
                  size: 20,
                ),
              ),
              if (hasFilters)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterRail() {
    final chips = <Widget>[];

    if (_statusFilter != 'ALL') {
      final label = _statusFilterOptions
          .firstWhere((o) => o.$1 == _statusFilter)
          .$2;
      chips.add(
        _buildRailChip(
          icon: Icons.flag_outlined,
          label: label,
          onRemove: () => setState(() => _statusFilter = 'ALL'),
        ),
      );
    }
    if (_wasteTypeFilter != 'ALL') {
      chips.add(
        _buildRailChip(
          icon: Icons.category_outlined,
          label: _wasteTypeFilter.replaceAll('_', ' '),
          onRemove: () => setState(() => _wasteTypeFilter = 'ALL'),
        ),
      );
    }
    final searchText = _requestSearchController.text.trim();
    if (searchText.isNotEmpty) {
      chips.add(
        _buildRailChip(
          icon: Icons.search_rounded,
          label: '"$searchText"',
          onRemove: () {
            _requestSearchController.clear();
            setState(() {});
          },
        ),
      );
    }
    chips.add(
      TextButton(
        onPressed: () {
          _requestSearchController.clear();
          setState(() {
            _statusFilter = 'ALL';
            _wasteTypeFilter = 'ALL';
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Clear all',
          style: TextStyle(
            color: AppColors.emerald700,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }

  Widget _buildRailChip({
    required IconData icon,
    required String label,
    required VoidCallback onRemove,
  }) {
    return Material(
      color: AppColors.emerald50,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.emerald700, size: 13),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.emerald700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.emerald600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openRequestsFilterSheet() async {
    final wasteTypes = _availableWasteTypesForFilter;
    var localStatus = _statusFilter;
    var localWasteType = _wasteTypeFilter;

    final shouldApply = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                localStatus = 'ALL';
                                localWasteType = 'ALL';
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (value, label) in _statusFilterOptions)
                            ChoiceChip(
                              label: Text(label),
                              selected: localStatus == value,
                              onSelected: (_) =>
                                  setSheetState(() => localStatus = value),
                              selectedColor: AppColors.emerald600,
                              labelStyle: TextStyle(
                                color: localStatus == value
                                    ? Colors.white
                                    : AppColors.grey700,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: localStatus == value
                                    ? AppColors.emerald600
                                    : AppColors.grey300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Waste Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (wasteTypes.isEmpty)
                        const Text(
                          'No waste types to filter yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('All types'),
                              selected: localWasteType == 'ALL',
                              onSelected: (_) => setSheetState(
                                () => localWasteType = 'ALL',
                              ),
                              selectedColor: AppColors.emerald600,
                              labelStyle: TextStyle(
                                color: localWasteType == 'ALL'
                                    ? Colors.white
                                    : AppColors.grey700,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: localWasteType == 'ALL'
                                    ? AppColors.emerald600
                                    : AppColors.grey300,
                              ),
                            ),
                            for (final type in wasteTypes)
                              ChoiceChip(
                                label: Text(type.replaceAll('_', ' ')),
                                selected: localWasteType == type,
                                onSelected: (_) => setSheetState(
                                  () => localWasteType = type,
                                ),
                                selectedColor: AppColors.emerald600,
                                labelStyle: TextStyle(
                                  color: localWasteType == type
                                      ? Colors.white
                                      : AppColors.grey700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: localWasteType == type
                                      ? AppColors.emerald600
                                      : AppColors.grey300,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Apply Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (shouldApply != true || !mounted) return;
    setState(() {
      _statusFilter = localStatus;
      _wasteTypeFilter = localWasteType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const CitizenHeader(name: 'Requests'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),
                  buildActionButtons(),
                  const SizedBox(height: 20),
                  if (showMyRequests)
                    buildRequestsList()
                  else
                    buildRequestForm(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 3),
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => showMyRequests = false);
            },
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
            onPressed: () async {
              setState(() => showMyRequests = true);
              await _loadRequests();
            },
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

  Widget buildRequestsList() {
    if (_loadingRequests) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.grey400),
            SizedBox(height: 12),
            Text(
              'No requests yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Create your first collection request and nearby third-party collectors will start sending offers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey600,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredRequests;
    if (filtered.isEmpty) {
      return Column(
        children: [
          _buildRequestsFilterBar(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 12),
                Text(
                  'No matches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Try changing the status, waste type, or search terms.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildRequestsFilterBar(),
        ...filtered.map((request) {
          final statusStyle = _statusStyle(request.status);
          final canOpenOffers =
              request.offersCount > 0 ||
              request.status == 'OPEN' ||
              request.status == 'ASSIGNED';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: canOpenOffers ? () => _openRequestDetail(request) : null,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(12),
                        image: request.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(request.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: request.photoUrl == null
                          ? Icon(
                              _iconForWasteType(request.wasteType),
                              color: AppColors.grey700,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  request.wasteType.replaceAll('_', ' '),
                                  style: const TextStyle(
                                    color: AppColors.citizenGrey900,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusStyle.bg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusStyle.label,
                                  style: TextStyle(
                                    color: statusStyle.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.citizenGrey600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _requestSubtitle(request),
                                  style: const TextStyle(
                                    color: AppColors.citizenGrey600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(request.preferredDate),
                                style: const TextStyle(
                                  color: AppColors.citizenGrey500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (request.offersCount > 0)
                                const Text(
                                  'View offers',
                                  style: TextStyle(
                                    color: AppColors.emerald600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.emerald50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.emerald200, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.emerald600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tap any open request with offers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'You can review collector price proposals and accept the one that fits best.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.emerald700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRequestForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentStep == 1
                ? 'Request Collection'
                : currentStep == 2
                ? 'Pickup Schedule'
                : 'Contact Details',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step $currentStep of 3',
            style: const TextStyle(fontSize: 13, color: AppColors.grey600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep / 3,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.emerald600,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 28),
          if (currentStep == 1) ..._buildStep1Content(),
          if (currentStep == 2) ..._buildStep2Content(),
          if (currentStep == 3) ..._buildStep3Content(),
          if (currentStep == 1)
            _navigationButton(
              label: 'Next',
              icon: Icons.arrow_forward,
              onPressed: () {
                if (selectedWasteType == null || selectedQuantity == null) {
                  _showSnackBar(
                    'Please complete the waste type and quantity fields first.',
                    isError: true,
                  );
                  return;
                }
                setState(() => currentStep++);
              },
            ),
          if (currentStep > 1)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => currentStep--);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey900,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.grey300,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            if (currentStep < 3) {
                              if (selectedPickupDate == null ||
                                  selectedTimeSlot == null ||
                                  _pickupLocation == null ||
                                  _addressController.text.trim().isEmpty) {
                                _showSnackBar(
                                  'Please complete the pickup details first.',
                                  isError: true,
                                );
                                return;
                              }
                              setState(() => currentStep++);
                            } else {
                              _submitRequest();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_submitting)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else if (currentStep == 3)
                          const Icon(Icons.check_circle_outline, size: 18)
                        else
                          const Icon(Icons.arrow_forward, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _submitting
                              ? 'Submitting...'
                              : currentStep == 3
                              ? 'Submit Request'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _navigationButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep1Content() {
    return [
      buildDropdownField(
        label: 'What needs to be collected?',
        hint: 'Select waste type',
        value: selectedWasteType,
        items: _wasteTypeItems,
        onChanged: (value) => setState(() => selectedWasteType = value),
      ),
      const SizedBox(height: 20),
      buildDropdownField(
        label: 'Estimated quantity',
        hint: 'Select approximate amount',
        value: selectedQuantity,
        items: _quantityItems,
        onChanged: (value) => setState(() => selectedQuantity = value),
      ),
      const SizedBox(height: 36),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.emerald50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emerald200, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.emerald600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collection Info',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Third-party collectors will see your request and send offers through the app.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.emerald700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildStep2Content() {
    return [
      const Text(
        'Preferred pickup date *',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedPickupDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            setState(() => selectedPickupDate = picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.grey400,
              ),
              const SizedBox(width: 12),
              Text(
                selectedPickupDate != null
                    ? _formatDate(selectedPickupDate!)
                    : 'Select date',
                style: TextStyle(
                  fontSize: 14,
                  color: selectedPickupDate != null
                      ? AppColors.grey900
                      : AppColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      buildDropdownField(
        label: 'Preferred time slot *',
        hint: 'Select time slot',
        value: selectedTimeSlot,
        items: _timeSlotItems,
        onChanged: (value) => setState(() => selectedTimeSlot = value),
      ),
      const SizedBox(height: 20),
      const Text(
        'Pickup location *',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _addressController,
        decoration: InputDecoration(
          hintText: 'Enter pickup address',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey400),
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.grey400,
          ),
          filled: true,
          fillColor: AppColors.grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.emerald700,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _openPickupLocationPicker,
          icon: const Icon(Icons.map_outlined, size: 18),
          label: Text(
            _pickupLocation == null
                ? 'Choose on map'
                : 'Change pickup location',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.emerald700,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.emerald200, width: 1.2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      _buildPickupLocationCard(),
      const SizedBox(height: 6),
      const Text(
        'Use the map to place your pickup point, then add the address as a clear location label.',
        style: TextStyle(fontSize: 11, color: AppColors.grey500),
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildPickupLocationCard() {
    final location = _pickupLocation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: location == null ? AppColors.grey50 : AppColors.emerald50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: location == null ? AppColors.grey300 : AppColors.emerald200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: location == null
                  ? AppColors.grey300
                  : AppColors.emerald600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              location == null ? Icons.location_off_outlined : Icons.place,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location == null
                      ? 'No pickup point selected'
                      : 'Pickup point selected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: location == null
                        ? AppColors.grey700
                        : AppColors.emerald700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location == null
                      ? 'Tap Choose on map to place the pickup point.'
                      : 'Lat ${location.latitude.toStringAsFixed(5)}, Lng ${location.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStep3Content() {
    return [
      const Text(
        'Contact phone *',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Your phone number',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey400),
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: AppColors.grey400,
          ),
          filled: true,
          fillColor: AppColors.grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.emerald700,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Collectors will contact you on this number',
        style: TextStyle(fontSize: 11, color: AppColors.grey500),
      ),
      const SizedBox(height: 20),
      const Text(
        'Request photo (Optional)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickRequestPhoto,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  color: AppColors.grey100,
                  alignment: Alignment.center,
                  child: _requestPhotoPath == null
                      ? const Icon(
                          Icons.photo_camera_back_outlined,
                          color: AppColors.grey500,
                          size: 26,
                        )
                      : Image.file(
                          File(_requestPhotoPath!),
                          fit: BoxFit.cover,
                          cacheWidth: 192,
                          cacheHeight: 192,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.grey500,
                            size: 26,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _requestPhotoPath == null
                          ? 'Tap to choose image from gallery'
                          : 'Image selected. Tap to change.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This image is uploaded with your request and shown to collectors.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Additional notes (Optional)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Any special instructions or details...',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey400),
          filled: true,
          fillColor: AppColors.grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.emerald700,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.emerald700,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestOffersSheet extends StatelessWidget {
  final CollectionRequestModel request;
  final Future<void> Function(CollectionOfferModel offer) onAccept;
  final Future<void> Function(CollectionOfferModel offer) onReject;
  final Future<void> Function(CollectionOfferModel offer) onConfirm;

  const _RequestOffersSheet({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onConfirm,
  });

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$date  $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.wasteType.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.addressLine,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald200),
                  ),
                  child: Text(
                    request.offers.isEmpty
                        ? 'No offers yet. Collectors will appear here once they respond.'
                        : '${request.offers.length} collector offer${request.offers.length == 1 ? '' : 's'} available for this request.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.emerald900,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...request.offers.map((offer) {
                  final pending =
                      offer.status == 'PENDING' && request.status == 'OPEN';
                  final accepted = offer.status == 'ACCEPTED';
                  final completedUnrated =
                      offer.status == 'COMPLETED' && offer.citizenRating == null;
                  final rated = offer.citizenRating != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                offer.collectorName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accepted
                                    ? AppColors.emerald200
                                    : AppColors.grey200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                offer.status.toLowerCase(),
                                style: TextStyle(
                                  color: accepted
                                      ? AppColors.emerald900
                                      : AppColors.grey700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((offer.collectorCompany ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            offer.collectorCompany!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              size: 16,
                              color: AppColors.emerald600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LKR ${offer.pricePerUnit.toStringAsFixed(2)} (${offer.priceUnit})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: AppColors.blue600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDateTime(offer.proposedPickupAt),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        if ((offer.messageToCitizen ?? '').isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            offer.messageToCitizen!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey700,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (pending) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => onReject(offer),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.grey700,
                                    side: const BorderSide(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => onAccept(offer),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald600,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (completedUnrated) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => onConfirm(offer),
                              icon: const Icon(Icons.star_rounded, size: 18),
                              label: const Text('Rate & Confirm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                        if (rated) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (var i = 1; i <= 5; i++)
                                Icon(
                                  i <= offer.citizenRating!
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: AppColors.amber600,
                                  size: 18,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                '${offer.citizenRating}/5',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ],
                          ),
                          if ((offer.citizenFeedback ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              offer.citizenFeedback!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingResult {
  final int rating;
  final String? feedback;
  const _RatingResult(this.rating, this.feedback);
}

class _RateOfferDialog extends StatefulWidget {
  const _RateOfferDialog();

  @override
  State<_RateOfferDialog> createState() => _RateOfferDialogState();
}

class _RateOfferDialogState extends State<_RateOfferDialog> {
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
      title: const Text('Rate this collector'),
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
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
              border: OutlineInputBorder(),
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
            Navigator.of(context).pop(
              _RatingResult(_rating, text.isEmpty ? null : text),
            );
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
