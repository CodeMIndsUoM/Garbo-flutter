import 'dart:io';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_constants.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_helpers.dart';
import 'package:garbo_swms/presentation/citizen/widgets/citizen_dropdown_field.dart';
import 'package:garbo_swms/presentation/citizen/widgets/citizen_waste_type_checklist.dart';
import 'package:latlong2/latlong.dart';

/// The multi-step collection request form (3 steps).
class RequestForm extends StatefulWidget {
  final Set<String> selectedWasteTypes;
  final String? selectedQuantity;
  final DateTime? selectedPickupDate;
  final String? selectedTimeSlot;
  final LatLng? pickupLocation;
  final String? requestPhotoPath;
  final bool submitting;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final ValueChanged<Set<String>> onWasteTypesChanged;
  final ValueChanged<String?> onQuantityChanged;
  final ValueChanged<DateTime?> onPickupDateChanged;
  final ValueChanged<String?> onTimeSlotChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickLocation;
  final VoidCallback onSubmit;
  final void Function(String message, {bool isError}) showSnackBar;

  const RequestForm({
    super.key,
    required this.selectedWasteTypes,
    required this.selectedQuantity,
    required this.selectedPickupDate,
    required this.selectedTimeSlot,
    required this.pickupLocation,
    required this.requestPhotoPath,
    required this.submitting,
    required this.addressController,
    required this.phoneController,
    required this.notesController,
    required this.onWasteTypesChanged,
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

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentStep == 1
              ? 'Request Collection'
              : currentStep == 2
              ? 'Pickup Schedule'
              : 'Contact Details',
          style: AppTypography.titleLg,
        ),
        const SizedBox(height: 8),
        Text('Step $currentStep of 3', style: AppTypography.bodySm),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: currentStep / 3),
        const SizedBox(height: 24),
        if (currentStep == 1) ..._buildStep1Content(),
        if (currentStep == 2) ..._buildStep2Content(),
        if (currentStep == 3) ..._buildStep3Content(),
        const SizedBox(height: 32),
        if (currentStep == 1)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (widget.selectedWasteTypes.isEmpty ||
                    widget.selectedQuantity == null) {
                  widget.showSnackBar(
                    'Please select at least one waste type and a quantity.',
                    isError: true,
                  );
                  return;
                }
                setState(() => currentStep++);
              },
              child: const Text('Next'),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => currentStep--),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
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
                  child: Text(
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
    );
  }

  List<Widget> _buildStep1Content() {
    return [
      CitizenWasteTypeChecklist(
        selected: widget.selectedWasteTypes,
        onChanged: widget.onWasteTypesChanged,
      ),
      const SizedBox(height: 20),
      _buildDropdownField(
        label: 'Estimated quantity',
        options: quantityItems,
        value: widget.selectedQuantity,
        onChanged: widget.onQuantityChanged,
      ),
    ];
  }

  List<Widget> _buildStep2Content() {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.calendar_today_outlined,
          color: AppColors.green700,
        ),
        title: Text(
          widget.selectedPickupDate != null
              ? formatRequestDate(widget.selectedPickupDate!)
              : 'Preferred pickup date *',
          style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
        ),
        subtitle: widget.selectedPickupDate == null
            ? Text('Tap to select a date', style: AppTypography.bodySm)
            : null,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: widget.selectedPickupDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            widget.onPickupDateChanged(picked);
          }
        },
      ),
      const SizedBox(height: 16),
      _buildDropdownField(
        label: 'Preferred time slot',
        options: timeSlotItems,
        value: widget.selectedTimeSlot,
        onChanged: widget.onTimeSlotChanged,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: widget.addressController,
        decoration: const InputDecoration(
          labelText: 'Pickup address *',
          hintText: 'Enter pickup address',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: widget.onPickLocation,
        icon: const Icon(Icons.map_outlined),
        label: Text(
          widget.pickupLocation == null
              ? 'Choose on map'
              : 'Change pickup location',
        ),
      ),
      if (widget.pickupLocation != null) ...[
        const SizedBox(height: 8),
        Text(
          'Lat ${widget.pickupLocation!.latitude.toStringAsFixed(5)}, '
          'Lng ${widget.pickupLocation!.longitude.toStringAsFixed(5)}',
          style: AppTypography.bodySm,
        ),
      ],
    ];
  }

  List<Widget> _buildStep3Content() {
    return [
      TextField(
        controller: widget.phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Contact phone *',
          hintText: 'Your phone number',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: widget.onPickPhoto,
        icon: const Icon(Icons.photo_camera_outlined),
        label: Text(
          widget.requestPhotoPath == null
              ? 'Add Photo (Optional)'
              : 'Photo Selected',
        ),
      ),
      if (widget.requestPhotoPath != null) ...[
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(widget.requestPhotoPath!),
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
      const SizedBox(height: 16),
      TextField(
        controller: widget.notesController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Additional notes (Optional)',
          hintText: 'Any special instructions or details...',
        ),
      ),
    ];
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return CitizenDropdownField(
      label: label,
      options: options,
      value: value,
      onChanged: onChanged,
    );
  }
}
