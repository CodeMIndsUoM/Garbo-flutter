import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/pages/pickup_location_picker_page.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_helpers.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/widgets/rate_offer_dialog.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/widgets/request_action_buttons.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/widgets/request_form.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/widgets/request_offers_sheet.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/widgets/requests_filter_bar.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/widgets/requests_list.dart';
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

  String? selectedWasteType;
  String? selectedQuantity;
  DateTime? selectedPickupDate;
  String? selectedTimeSlot;
  LatLng? _pickupLocation;
  bool showMyRequests = false;
  bool _submitting = false;
  bool _loadingRequests = false;
  bool _isHandlingOfferAction = false;
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

  // ─── Lifecycle ──────────────────────────────────────────────────────

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

  // ─── Polling ────────────────────────────────────────────────────────

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

  // ─── Data loading ───────────────────────────────────────────────────

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

  // ─── Form submission ────────────────────────────────────────────────

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
          'wasteType': mapWasteType(selectedWasteType!),
          'quantityLabel': selectedQuantity,
          'quantityKgEstimate': null,
          'addressLine': _addressController.text.trim(),
          'latitude': _pickupLocation!.latitude,
          'longitude': _pickupLocation!.longitude,
          'preferredDate': formatRequestDate(selectedPickupDate!),
          'preferredSlot': mapTimeSlot(selectedTimeSlot!),
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

  // ─── User actions ───────────────────────────────────────────────────

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
        builder: (sheetCtx) => RequestOffersSheet(
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

  // ─── Offer actions ──────────────────────────────────────────────────

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
    if (_isHandlingOfferAction) return;
    final result = await showDialog<RatingResult>(
      context: sheetCtx,
      builder: (_) => const RateOfferDialog(),
    );
    if (result == null) return;
    setState(() => _isHandlingOfferAction = true);
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
    } finally {
      if (mounted) {
        setState(() => _isHandlingOfferAction = false);
      }
    }
  }

  Future<void> _handleOfferAction(
    int requestId,
    int offerId,
    bool accept,
  ) async {
    if (_isHandlingOfferAction) return;
    setState(() => _isHandlingOfferAction = true);
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
    } finally {
      if (mounted) {
        setState(() => _isHandlingOfferAction = false);
      }
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : AppColors.emerald600,
      ),
    );
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

  // ─── Build ──────────────────────────────────────────────────────────

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
                  RequestActionButtons(
                    showMyRequests: showMyRequests,
                    onNewRequest: () {
                      setState(() => showMyRequests = false);
                    },
                    onMyRequests: () async {
                      setState(() => showMyRequests = true);
                      await _loadRequests();
                    },
                  ),
                  const SizedBox(height: 20),
                  if (showMyRequests)
                    RequestsList(
                      loading: _loadingRequests,
                      allRequests: _requests,
                      filteredRequests: _filteredRequests,
                      filterBar: RequestsFilterBar(
                        statusFilter: _statusFilter,
                        wasteTypeFilter: _wasteTypeFilter,
                        searchController: _requestSearchController,
                        availableWasteTypes: _availableWasteTypesForFilter,
                        onStatusFilterChanged: (v) =>
                            setState(() => _statusFilter = v),
                        onWasteTypeFilterChanged: (v) =>
                            setState(() => _wasteTypeFilter = v),
                        onChanged: () => setState(() {}),
                      ),
                      onRequestTap: _openRequestDetail,
                    )
                  else
                    RequestForm(
                      selectedWasteType: selectedWasteType,
                      selectedQuantity: selectedQuantity,
                      selectedPickupDate: selectedPickupDate,
                      selectedTimeSlot: selectedTimeSlot,
                      pickupLocation: _pickupLocation,
                      requestPhotoPath: _requestPhotoPath,
                      submitting: _submitting,
                      addressController: _addressController,
                      phoneController: _phoneController,
                      notesController: _notesController,
                      onWasteTypeChanged: (v) =>
                          setState(() => selectedWasteType = v),
                      onQuantityChanged: (v) =>
                          setState(() => selectedQuantity = v),
                      onPickupDateChanged: (v) =>
                          setState(() => selectedPickupDate = v),
                      onTimeSlotChanged: (v) =>
                          setState(() => selectedTimeSlot = v),
                      onPickPhoto: _pickRequestPhoto,
                      onPickLocation: _openPickupLocationPicker,
                      onSubmit: _submitRequest,
                      showSnackBar: _showSnackBar,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 3),
    );
  }
}
