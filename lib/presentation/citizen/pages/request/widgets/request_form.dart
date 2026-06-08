import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_constants.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_helpers.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';
import 'package:garbo_swms/presentation/shared/widgets/option_select_chips.dart';
import 'package:latlong2/latlong.dart';

/// The multi-step collection request form (3 steps).
class RequestForm extends StatefulWidget {
  final String? selectedWasteType;
  final String? selectedQuantity;
  final DateTime? selectedPickupDate;
  final String? selectedTimeSlot;
  final LatLng? pickupLocation;
  final String? requestPhotoPath;
  final bool submitting;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final ValueChanged<String?> onWasteTypeChanged;
  final ValueChanged<String?> onQuantityChanged;
  final ValueChanged<DateTime?> onPickupDateChanged;
  final ValueChanged<String?> onTimeSlotChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickLocation;
  final VoidCallback onSubmit;
  final void Function(String message, {bool isError}) showSnackBar;

  const RequestForm({
    super.key,
    required this.selectedWasteType,
    required this.selectedQuantity,
    required this.selectedPickupDate,
    required this.selectedTimeSlot,
    required this.pickupLocation,
    required this.requestPhotoPath,
    required this.submitting,
    required this.addressController,
    required this.phoneController,
    required this.notesController,
    required this.onWasteTypeChanged,
    required this.onQuantityChanged,
    required this.onPickupDateChanged,
    required this.onTimeSlotChanged,
    required this.onPickPhoto,
    required this.onPickLocation,
    required this.onSubmit,
    required this.showSnackBar,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  int currentStep = 1;

  Color get _green => Theme.of(context).colorScheme.primary;

  TextStyle get _labelStyle => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );

  TextStyle get _hintStyle => TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        height: 1.4,
      );

  BoxDecoration _borderBox({bool highlighted = false}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? _green
              : _green.withValues(alpha: 0.35),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CitizenSurfaceCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentStep == 1
                  ? 'Request Collection'
                  : currentStep == 2
                  ? 'Pickup Schedule'
                  : 'Contact Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Step $currentStep of 3', style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: currentStep / 3),
            const SizedBox(height: 28),
            if (currentStep == 1) ..._buildStep1Content(),
            if (currentStep == 2) ..._buildStep2Content(),
            if (currentStep == 3) ..._buildStep3Content(),
            if (currentStep == 1)
              _navigationButton(
                label: 'Next',
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (widget.selectedWasteType == null ||
                      widget.selectedQuantity == null) {
                    widget.showSnackBar(
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
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => currentStep--),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.submitting
                          ? null
                          : () {
                              if (currentStep < 3) {
                                if (widget.selectedPickupDate == null ||
                                    widget.selectedTimeSlot == null ||
                                    widget.pickupLocation == null ||
                                    widget.addressController.text.trim().isEmpty) {
                                  widget.showSnackBar(
                                    'Please complete the pickup details first.',
                                    isError: true,
                                  );
                                  return;
                                }
                                setState(() => currentStep++);
                              } else {
                                widget.onSubmit();
                              }
                            },
                      icon: widget.submitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              currentStep == 3
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward,
                              size: 18,
                            ),
                      label: Text(
                        widget.submitting
                            ? 'Submitting...'
                            : currentStep == 3
                            ? 'Submit Request'
                            : 'Next',
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
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  List<Widget> _buildStep1Content() {
    return [
      OptionSelectChips(
        label: 'What needs to be collected?',
        options: wasteTypeItems,
        selected: widget.selectedWasteType,
        onChanged: widget.onWasteTypeChanged,
      ),
      const SizedBox(height: 20),
      OptionSelectChips(
        label: 'Estimated quantity',
        options: quantityItems,
        selected: widget.selectedQuantity,
        onChanged: widget.onQuantityChanged,
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildStep2Content() {
    return [
      Text('Preferred pickup date *', style: _labelStyle),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: widget.selectedPickupDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            widget.onPickupDateChanged(picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: _borderBox(
            highlighted: widget.selectedPickupDate != null,
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: _green),
              const SizedBox(width: 12),
              Text(
                widget.selectedPickupDate != null
                    ? formatRequestDate(widget.selectedPickupDate!)
                    : 'Select date',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.selectedPickupDate != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      OptionSelectChips(
        label: 'Preferred time slot *',
        options: timeSlotItems,
        selected: widget.selectedTimeSlot,
        onChanged: widget.onTimeSlotChanged,
      ),
      const SizedBox(height: 20),
      Text('Pickup location *', style: _labelStyle),
      const SizedBox(height: 8),
      TextField(
        controller: widget.addressController,
        decoration: const InputDecoration(
          hintText: 'Enter pickup address',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: widget.onPickLocation,
          icon: const Icon(Icons.map_outlined, size: 18),
          label: Text(
            widget.pickupLocation == null
                ? 'Choose on map'
                : 'Change pickup location',
          ),
        ),
      ),
      const SizedBox(height: 10),
      _buildPickupLocationCard(),
      const SizedBox(height: 6),
      Text(
        'Use the map to place your pickup point, then add the address as a clear location label.',
        style: _hintStyle,
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildPickupLocationCard() {
    final location = widget.pickupLocation;
    final selected = location != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _borderBox(highlighted: selected),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? _green : _green.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              selected ? Icons.place : Icons.location_off_outlined,
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
                  selected ? 'Pickup point selected' : 'No pickup point selected',
                  style: _labelStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  selected
                      ? 'Lat ${location.latitude.toStringAsFixed(5)}, Lng ${location.longitude.toStringAsFixed(5)}'
                      : 'Tap Choose on map to place the pickup point.',
                  style: _hintStyle,
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
      Text('Contact phone *', style: _labelStyle),
      const SizedBox(height: 8),
      TextField(
        controller: widget.phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: 'Your phone number',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
      ),
      const SizedBox(height: 6),
      Text('Collectors will contact you on this number', style: _hintStyle),
      const SizedBox(height: 20),
      Text('Request photo (Optional)', style: _labelStyle),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: widget.onPickPhoto,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: _borderBox(highlighted: widget.requestPhotoPath != null),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _green.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: widget.requestPhotoPath == null
                      ? Icon(
                          Icons.photo_camera_back_outlined,
                          color: _green.withValues(alpha: 0.55),
                          size: 26,
                        )
                      : Image.file(
                          File(widget.requestPhotoPath!),
                          fit: BoxFit.cover,
                          cacheWidth: 192,
                          cacheHeight: 192,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported_outlined,
                            color: _green.withValues(alpha: 0.55),
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
                      widget.requestPhotoPath == null
                          ? 'Tap to choose image from gallery'
                          : 'Image selected. Tap to change.',
                      style: _labelStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This image is uploaded with your request and shown to collectors.',
                      style: _hintStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text('Additional notes (Optional)', style: _labelStyle),
      const SizedBox(height: 8),
      TextField(
        controller: widget.notesController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Any special instructions or details...',
        ),
      ),
      const SizedBox(height: 24),
    ];
  }
}
