import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_constants.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_helpers.dart';
import 'package:latlong2/latlong.dart';

/// The multi-step collection request form (3 steps).
///
/// Manages its own `currentStep` state internally. All form field values
/// are owned by the parent and passed in as props + callbacks.
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
  // DEVELOPER NOTE: Active step tracker (controls which page panel compiles in the UI).
  int currentStep = 1;

  @override
  Widget build(BuildContext context) {
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
                if (widget.selectedWasteType == null || widget.selectedQuantity == null) {
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
                        if (widget.submitting)
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
                          widget.submitting
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

  // DEVELOPER NOTE: Step 1 Content Panel (Waste Category and Quantity selection).
  // Layout padding, dropdown options, and style settings are configured below.
  List<Widget> _buildStep1Content() {
    return [
      _buildDropdownField(
        label: 'What needs to be collected?',
        hint: 'Select waste type',
        value: widget.selectedWasteType,
        items: wasteTypeItems,
        onChanged: widget.onWasteTypeChanged,
      ),
      const SizedBox(height: 20),
      _buildDropdownField(
        label: 'Estimated quantity',
        hint: 'Select approximate amount',
        value: widget.selectedQuantity,
        items: quantityItems,
        onChanged: widget.onQuantityChanged,
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

  // DEVELOPER NOTE: Step 2 Content Panel (Pickup Date selection, Time Slot, and Map Location picker).
  // Sizing parameters, border styles, input decoration paddings, and button sizes are adjusted in this block.
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
                widget.selectedPickupDate != null
                    ? formatRequestDate(widget.selectedPickupDate!)
                    : 'Select date',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.selectedPickupDate != null
                      ? AppColors.grey900
                      : AppColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      _buildDropdownField(
        label: 'Preferred time slot *',
        hint: 'Select time slot',
        value: widget.selectedTimeSlot,
        items: timeSlotItems,
        onChanged: widget.onTimeSlotChanged,
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
        controller: widget.addressController,
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
          onPressed: widget.onPickLocation,
          icon: const Icon(Icons.map_outlined, size: 18),
          label: Text(
            widget.pickupLocation == null
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
    final location = widget.pickupLocation;

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

  // DEVELOPER NOTE: Step 3 Content Panel (Contact Phone input, and Request Photo attachment).
  // Field borders, text styles, element heights, and alignment configurations are detailed below.
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
        controller: widget.phoneController,
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
        onTap: widget.onPickPhoto,
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
                  child: widget.requestPhotoPath == null
                      ? const Icon(
                          Icons.photo_camera_back_outlined,
                          color: AppColors.grey500,
                          size: 26,
                        )
                      : Image.file(
                          File(widget.requestPhotoPath!),
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
                      widget.requestPhotoPath == null
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
        controller: widget.notesController,
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

  Widget _buildDropdownField({
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
